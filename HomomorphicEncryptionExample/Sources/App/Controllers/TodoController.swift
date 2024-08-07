import Fluent
import Vapor
import DependencyInjection
import HomomorphicEncryption
import PrivateInformationRetrieval

struct TodoController: RouteCollection {
    typealias Server = KeywordPirServer<MulPirServer<Bfv<UInt64>>>
    
    @Injected(Container.HEContext) private var context
    
    func boot(routes: RoutesBuilder) throws {
        let todos = routes.grouped("todo")

        todos.post(use: self.index)
    }

    @Sendable
    func index(req: Request) async throws -> PrivateInformationRetrieval.Response<MulPir<Bfv<UInt64>>.Scheme> {
        let pirQuery = try req.content.decode(PIRQuery.self)
        // process database
        let allTodos = try await Todo.query(on: req.db).all()
        let keywordCollection = try allTodos.map {
            KeywordValuePair(keyword: [UInt8]($0.id!.data),
                             value: [UInt8](try JSONEncoder().encode($0)))
        }
        let maxSerializedBucketSize = keywordCollection.map { $0.keyword.count + $0.value.count }.max()!
        let processedDatabase = try Server.process(database: keywordCollection,
                                                   config: .init(dimensionCount: 2,
                                                                 cuckooTableConfig: .defaultKeywordPir(maxSerializedBucketSize: maxSerializedBucketSize),
                                                                 unevenDimensions: true,
                                                                 keyCompression: .noCompression),
                                                   with: try context.get())

        let server = try Server(context: try context.get(),
                                processed: processedDatabase)
        let response = try server.computeResponse(to: pirQuery.query,
                                                  using: .init(deserialize: pirQuery.evaluationKey,
                                                               context: try context.get()))
        return response
    }
}

struct PIRQuery: Content {
    let evaluationKey: SerializedEvaluationKey<UInt64>
    let query: Query<MulPir<Bfv<UInt64>>.Scheme>
}

extension Container {
    // WARNING: This is more expensive than you think, for now callers should use execute the first resolution on a background thread
    // TODO: Move to an actor and refactor code to get this started as early as possible/reasonable in the lifecycle
    static let HEContext = Factory(scope: .cached) {
        let encryptParams = try EncryptionParameters<Bfv<UInt64>>(from: .insecure_n_8_logq_5x18_logt_5)
        let context = try Context(encryptionParameters: encryptParams)
        return context
    }
}

extension UUID {
    var data: Data {
        withUnsafeBytes(of: self.uuid, { Data($0) })
    }
}














































extension PrivateInformationRetrieval.Response<MulPir<Bfv<UInt64>>.Scheme>: @retroactive AsyncResponseEncodable { }
extension PrivateInformationRetrieval.Response<MulPir<Bfv<UInt64>>.Scheme>: @retroactive AsyncRequestDecodable { }
extension PrivateInformationRetrieval.Response<MulPir<Bfv<UInt64>>.Scheme>: @retroactive ResponseEncodable { }
extension PrivateInformationRetrieval.Response<MulPir<Bfv<UInt64>>.Scheme>: @retroactive RequestDecodable { }
extension PrivateInformationRetrieval.Response<MulPir<Bfv<UInt64>>.Scheme>: @retroactive Codable { }
extension PrivateInformationRetrieval.Response<MulPir<Bfv<UInt64>>.Scheme>: @retroactive Content {
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let _ = try container.decode([[SerializedCiphertext<Ciphertext<Bfv<UInt64>, Coeff>.Scalar>]].self, forKey: .ciphertexts)
        self.init(ciphertexts: Container.responseWorkaround().ciphertexts)
//        self.init(ciphertexts: try serializedCipherTexts.map { try $0.map { try Ciphertext<Bfv<UInt64>, Coeff>(deserialize: $0, context: Container.HEContext()) } })
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(ciphertexts.map { try $0.map { try $0.serialize() } }, forKey: .ciphertexts)
        // Unfortunately, there seems to be a bug with the current implementation where trying to deserialize these cipher texts right after serializing throws an error. I'll eventually get around to submitting an issue on the library, but until then here's a hacky workaround.
        Container.responseWorkaround.register { self }
    }
    
    enum CodingKeys: String, CodingKey {
        case ciphertexts
    }
}

extension Container {
    static let responseWorkaround = Factory { () -> PrivateInformationRetrieval.Response<MulPir<Bfv<UInt64>>.Scheme> in
        fatalError()
    }
}

extension Query<MulPir<Bfv<UInt64>>.Scheme>: @retroactive AsyncResponseEncodable { }
extension Query<MulPir<Bfv<UInt64>>.Scheme>: @retroactive AsyncRequestDecodable { }
extension Query<MulPir<Bfv<UInt64>>.Scheme>: @retroactive ResponseEncodable { }
extension Query<MulPir<Bfv<UInt64>>.Scheme>: @retroactive RequestDecodable { }
extension Query<MulPir<Bfv<UInt64>>.Scheme>: @retroactive Codable { }
extension Query<MulPir<Bfv<UInt64>>.Scheme>: @retroactive Content {
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let indicesCount = try container.decode(Int.self, forKey: .indicesCount)
        let serializedCipherTexts = try container.decode([SerializedCiphertext<Ciphertext<Bfv<UInt64>, Bfv<UInt64>.CanonicalCiphertextFormat>.Scalar>].self, forKey: .ciphertexts)
        self.init(ciphertexts: try serializedCipherTexts.map { try Ciphertext(deserialize: $0, context: Container.HEContext()) }, indicesCount: indicesCount)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(indicesCount, forKey: .indicesCount)
        try container.encode(ciphertexts.map { try $0.serialize() }, forKey: .ciphertexts)
    }
    
    enum CodingKeys: String, CodingKey {
        case indicesCount
        case ciphertexts
    }
}

