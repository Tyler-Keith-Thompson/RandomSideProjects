import Fluent
import Vapor

extension Application {
    func routes() throws {
        get { req async in
            "It works!"
        }
        
        get("hello") { req async -> String in
            "Hello, world!"
        }
        
        try register(collection: TodoController())
    }
}
