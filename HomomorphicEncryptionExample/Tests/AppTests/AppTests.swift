@testable import App
import XCTVapor
import Fluent
import DependencyInjection
import Testing
import HomomorphicEncryption
import PrivateInformationRetrieval

extension Application {
    static var forTesting: Application {
        get async throws {
            Container.databaseInfo.register {
                (database: .sqlite(.memory), id: .sqlite)
            }
            let app = try await Application.make(.testing)
            app.http.server.configuration.reportMetrics = false
            try await app.configure()
            try await app.autoMigrate()
            app.clients.use { _ in
                FailClient()
            }
            return app
        }
    }
}

struct AppTests {
    @Test func getTodo() async throws {
        try await withTestContainer {
            let app = try await Application.forTesting
            async let _ = deferAsync {
                try? await app.autoRevert()
                try? await app.asyncShutdown()
            }
            
            let sample1 = Todo(title: "sample1") // encoded bytes 63
            let sample2 = Todo(title: "sample2") // encoded bytes 63
            try await sample1.save(on: app.db)
            try await sample2.save(on: app.db)
            let sampleTodos = [sample1, sample2]
            
            let firstId = try #require(sample1.id)
            // Create encrypted query
            let encryptParams = try EncryptionParameters<Bfv<UInt64>>(from: .insecure_n_8_logq_5x18_logt_5)
            let context = try Context(encryptionParameters: encryptParams)
            Container.HEContext.register { context }
            
            // You might be wondering where all the magic numbers come from
            // The short answer is, for this test they're easy to hard code
            // In a real application the client would have to ask the server for these values before making a request
            let client = KeywordPirClient<MulPirClient<Bfv<UInt64>>>(keywordParameter: .init(hashFunctionCount: 2),
                                                                     pirParameter: .init(entryCount: 2,
                                                                                         entrySizeInBytes: 74,
                                                                                         dimensions: [2, 1],
                                                                                         batchSize: 2,
                                                                                         evaluationKeyConfig: .init(galoisElements: [3, 5, 9], hasRelinearizationKey: true)),
                                                                     context: context)
            let secretKey = try context.generateSecretKey()
            let evaluationKey = try client.generateEvaluationKey(using: secretKey)
            let query = try client.generateQuery(at: [UInt8](firstId.data), using: secretKey)
            
            try await app.test(.POST, "todo", beforeRequest: { req in
                try req.content.encode(PIRQuery(evaluationKey: evaluationKey.serialize(),
                                                query: query))
            }, afterResponse: { res async throws in
                #expect(res.status == .ok)
                let response = try res.content.decode(PrivateInformationRetrieval.Response<MulPir<Bfv<UInt64>>.Scheme>.self)
                let decryptedResponse = try #require(try client.decrypt(response: response,
                                                                        at: [UInt8](firstId.data),
                                                                        using: secretKey))
                let todo = try JSONDecoder().decode(Todo.self, from: Data(decryptedResponse))
                #expect(todo == sample1)
            })
        }
    }
}

extension Todo: @retroactive Equatable {
    public static func == (lhs: Todo, rhs: Todo) -> Bool {
        lhs.id == rhs.id && lhs.title == rhs.title
    }
}
