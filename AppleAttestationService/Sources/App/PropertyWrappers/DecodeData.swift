//
//  DataDecoding.swift
//  
//
//  Created by Tyler Thompson on 6/19/23.
//

import Foundation
import AnyCodable

protocol DataCodingStrategy {
    associatedtype DataType: DataProtocol
}

protocol DataDecodableStrategy: DataCodingStrategy {
    associatedtype ValueType: Decodable
    static func decode(_ value: ValueType) throws -> DataType
}

@propertyWrapper
struct DecodeData<Coder: DataCodingStrategy> {
    public var wrappedValue: Coder.DataType

    public init(wrappedValue: Coder.DataType) {
        self.wrappedValue = wrappedValue
    }
}

extension DecodeData: Decodable where Coder: DataDecodableStrategy {
    init(from decoder: Decoder) throws {
        self.wrappedValue = try Coder.decode(Coder.ValueType(from: decoder))
    }
}

extension DecodeData: Equatable where Coder.DataType: Equatable {}
extension DecodeData: Hashable where Coder.DataType: Hashable {}

extension AnyCodable {
    enum CastError: Error {
        case unableToCast
    }
    func cast<T>(to type: T.Type) throws -> T {
        guard let val = value as? T else {
            throw CastError.unableToCast
        }
        return val
    }
    func cast<T>() throws -> T {
        guard let val = value as? T else {
            throw CastError.unableToCast
        }
        return val
    }
}

struct AnyStrategy<DataType: MutableDataProtocol>: DataDecodableStrategy {
    static func decode(_ value: AnyCodable) throws -> DataType {
        try Result {
            try ByteArrayStrategy<DataType>.decode(value.cast(to: [Int].self).map {
                guard $0 > 0 && $0 <= UInt8.max else {
                    throw AnyCodable.CastError.unableToCast
                }
                return UInt8($0)
            })
        }
        .merge(Result { try AnyBase64Strategy<DataType>.decode(value.cast()) })
        .merge(Result { try AnyCodableJSONStrategy<DataType>.decode(value) })
        .get()
    }
}

struct ByteArrayStrategy<DataType: MutableDataProtocol>: DataDecodableStrategy {
    static func decode(_ value: [UInt8]) throws -> DataType {
        DataType(value)
    }
}

struct Base64Strategy<DataType: MutableDataProtocol>: DataDecodableStrategy {
    static func decode(_ value: String) throws -> DataType {
        if let data = Data(base64Encoded: value) {
            return DataType(data)
        } else {
            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Invalid Base64 Format!"))
        }
    }
}

struct AnyBase64Strategy<DataType: MutableDataProtocol>: DataDecodableStrategy {
    static func decode(_ value: String) throws -> DataType {
        try Result { try Base64URLStrategy<DataType>.decode(value) }
            .merge(Result { try Base64Strategy<DataType>.decode(value) })
            .get()
    }
}

struct AnyCodableJSONStrategy<DataType: MutableDataProtocol>: DataDecodableStrategy {
    static func decode(_ value: AnyCodable) throws -> DataType {
        DataType(try JSONEncoder().encode(value))
    }
}

struct Base64URLStrategy<DataType: MutableDataProtocol>: DataDecodableStrategy {
    static func decode(_ value: String) throws -> DataType {
        if let data = value.base64Decoded() {
            return DataType(data)
        } else {
            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Invalid Base64 Format!"))
        }
    }
}

extension String {
    func base64Decoded() -> Data? {
        var encoded = replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")

        // Swift requires padding, but other languages don't always
        while encoded.count % 4 != 0 {
            encoded += "="
        }

        return Data(base64Encoded: encoded, options: .ignoreUnknownCharacters)
    }
}
