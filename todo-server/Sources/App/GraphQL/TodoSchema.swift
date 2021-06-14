//
//  File.swift
//  
//
//  Created by Tyler Thompson on 6/13/21.
//

import Foundation
import Graphiti
import Vapor

enum Schemas {
    // Definition of our GraphQL schema.
    static var todo: Schema<TodoResolver, Request> {
        get throws {
            try Schema<TodoResolver, Request> {
                Scalar(UUID.self)

                // Todo type with it's fields
                Type(Todo.self) {
                    Field("id", at: \.id)
                    Field("title", at: \.title)
                }

                Query {
                    Field("todos", at: TodoResolver.getAllTodos)
                    Field("todo", at: TodoResolver.getTodo) {
                        Argument("id", at: \.id)
                    }
                }

                Mutation {
                    Field("createTodo", at: TodoResolver.createTodo) {
                        Argument("title", at: \.title)
                    }

                    Field("deleteTodo", at: TodoResolver.deleteTodo) {
                        Argument("id", at: \.id)
                    }
                }
            }
        }
    }
}
