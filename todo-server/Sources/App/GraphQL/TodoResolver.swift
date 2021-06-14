//
//  File.swift
//  
//
//  Created by Tyler Thompson on 6/13/21.
//

import Graphiti
import Vapor

final class TodoResolver {
    func getAllTodos(request: Request, _: NoArguments) throws -> EventLoopFuture<[Todo]> {
        Todo.query(on: request.db).all()
    }

    struct GetTodoArguments: Codable {
        let id: UUID
    }
    func getTodo(request: Request, arguments: GetTodoArguments) throws -> EventLoopFuture<Todo> {
        Todo.find(arguments.id, on: request.db)
            .unwrap(or: Abort(.notFound))
    }

    struct CreateTodoArguments: Codable {
        let title: String
    }

    func createTodo(request: Request, arguments: CreateTodoArguments) throws -> EventLoopFuture<Todo> {
        let todo = Todo(title: arguments.title)
        return todo.create(on: request.db).map { todo }
    }

    struct DeleteTodoArguments: Codable {
        let id: UUID
    }

    func deleteTodo(request: Request, arguments: DeleteTodoArguments) throws -> EventLoopFuture<Todo> {
        Todo.find(arguments.id, on: request.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { todo in
                todo.delete(on: request.db).flatMap {
                    request.eventLoop.makeCompletedFuture(.success(todo))
                }
            }
    }
}
