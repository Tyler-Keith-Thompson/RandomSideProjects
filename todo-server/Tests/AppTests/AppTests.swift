@testable import App
import XCTVapor

final class AppTests: XCTestCase {
    func testGettingTodos() throws {
        let app = try Application.forTesting
        defer { app.shutdown() }

        let expectedTodos = [
            Todo(id: UUID(), title: UUID().uuidString),
            Todo(id: UUID(), title: UUID().uuidString)
        ]
        try expectedTodos.forEach { try $0.save(on: try XCTUnwrap(app.db(.sqlite))).wait() }

        try app.sendGraphBody("""
            {
                todos {
                    id
                    title
                }
            }
            """) { res in
            XCTAssertEqual(res.status, .ok)

            let todos = try res.content.decode([Todo].self, using: GraphQLContentDecoder(queryName: "todos"))

            XCTAssertEqual(todos.count, 2)
            XCTAssertEqual(todos.first?.id, expectedTodos.first?.id)
            XCTAssertEqual(todos.first?.title, expectedTodos.first?.title)
            XCTAssertEqual(todos.last?.id, expectedTodos.last?.id)
            XCTAssertEqual(todos.last?.title, expectedTodos.last?.title)
        }
    }

    func testGettingSingleTodo() throws {
        let app = try Application.forTesting
        defer { app.shutdown() }

        let expectedTodo = Todo(id: UUID(), title: UUID().uuidString)
        try expectedTodo.save(on: try XCTUnwrap(app.db(.sqlite))).wait()

        try app.sendGraphBody("""
            {
                todo(id: "\(try XCTUnwrap(expectedTodo.id))") {
                    id
                    title
                }
            }
            """) { res in
            XCTAssertEqual(res.status, .ok)

            let todo = try res.content.decode(Todo.self, using: GraphQLContentDecoder(queryName: "todo"))

            XCTAssertEqual(todo.id, expectedTodo.id)
            XCTAssertEqual(todo.title, expectedTodo.title)
        }
    }

    func testGettingSingleTodo_ReturnsNotFound_WhenTodoIDInvalid() throws {
        let app = try Application.forTesting
        defer { app.shutdown() }

        try app.sendGraphBody("""
            {
                todo(id: "\(UUID())") {
                    id
                    title
                }
            }
            """) { res in
            XCTAssertEqual(res.status, .ok)

            let errors = try JSONDecoder().decode([GraphQLError].self, from: res.body.extractingJSONContainer(named: "errors"))

            XCTAssertEqual(errors.count, 1)
            XCTAssertEqual(errors.first?.message, "Abort.404: Not Found")
            XCTAssertEqual(errors.first?.path, ["todo"])
        }
    }

    func testCreatingATodo() throws {
        let app = try Application.forTesting
        defer { app.shutdown() }

        try app.sendGraphBody("""
            mutation createTodo {
              createTodo(title: "Make stuff work") {
                id
                title
              }
            }
            """) { res in
            XCTAssertEqual(res.status, .ok)

            let createdTodo = try res.content.decode(Todo.self, using: GraphQLContentDecoder(queryName: "createTodo"))
            let foundTodoInDB = try Todo.find(createdTodo.id, on: app.db).wait()

            XCTAssertEqual(createdTodo.id, foundTodoInDB?.id)
            XCTAssertEqual(createdTodo.title, foundTodoInDB?.title)
        }
    }

    func testDeletingATodo() throws {
        let app = try Application.forTesting
        defer { app.shutdown() }

        let expectedTodo = Todo(id: UUID(), title: UUID().uuidString)
        try expectedTodo.save(on: try XCTUnwrap(app.db(.sqlite))).wait()

        try app.sendGraphBody("""
            mutation DeleteTodo {
              deleteTodo(id: "\(try XCTUnwrap(expectedTodo.id))") {
                id,
                title
              }
            }
            """) { res in
            XCTAssertEqual(res.status, .ok)

            let deletedTodo = try res.content.decode(Todo.self, using: GraphQLContentDecoder(queryName: "deleteTodo"))

            XCTAssertNil(try Todo.find(expectedTodo.id, on: app.db).wait())
            XCTAssertEqual(deletedTodo.id, expectedTodo.id)
            XCTAssertEqual(deletedTodo.title, expectedTodo.title)
        }
    }

    func testDeletingSingleTodo_ReturnsNotFound_WhenTodoIDInvalid() throws {
        let app = try Application.forTesting
        defer { app.shutdown() }

        try app.sendGraphBody("""
            mutation DeleteTodo {
              deleteTodo(id: "\(UUID())") {
                id,
                title
              }
            }
            """) { res in
            XCTAssertEqual(res.status, .ok)

            let errors = try JSONDecoder().decode([GraphQLError].self, from: res.body.extractingJSONContainer(named: "errors"))

            XCTAssertEqual(errors.count, 1)
            XCTAssertEqual(errors.first?.message, "Abort.404: Not Found")
            XCTAssertEqual(errors.first?.path, ["deleteTodo"])
        }
    }
}
