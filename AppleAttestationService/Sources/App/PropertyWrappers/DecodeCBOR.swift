//
//  File.swift
//  
//
//  Created by Tyler Thompson on 6/19/23.
//

import Foundation
import SwiftCBOR

@propertyWrapper
struct DecodeCBOR<Value: Decodable> {
    public var wrappedValue: Value

    public init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }
}

extension DecodeCBOR: Decodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let data = try container.decode(DecodeData<AnyBase64Strategy<Data>>.self).wrappedValue
        wrappedValue = try CodableCBORDecoder().decode(Value.self, from: data)
    }
}
