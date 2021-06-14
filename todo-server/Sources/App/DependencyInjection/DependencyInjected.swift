//
//  DependencyInjected.swift
//  
//
//  Created by Tyler Thompson on 6/13/21.
//
//  Original Work by: https://github.com/wwt/tdd201-apple-platforms/tree/completed/DependencyInjection

import Foundation
import Swinject

@propertyWrapper
struct DependencyInjected<Value> {
    let nameGetter: (() -> String?)
    let containerGetter: () -> Container

    public init(container: @escaping @autoclosure () -> Container = Container.default,
                name: @escaping @autoclosure (() -> String?) = nil) {
        self.nameGetter = name
        self.containerGetter = container
    }

    public lazy var wrappedValue: Value? = {
        containerGetter().resolve(Value.self, name: nameGetter())
    }()
}
