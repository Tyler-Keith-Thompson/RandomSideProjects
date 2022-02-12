//
//  FormURLEncoder.swift
//  
//
//  Created by Tyler Thompson on 2/12/22.
//

import Foundation
import Combine

public final class FormURLEncoder: TopLevelEncoder {
    public typealias Output = Data

    public func encode<T>(_ value: T) throws -> Data where T : Encodable {
        let formURLEncoding = FormURLEncoding()
        try value.encode(to: formURLEncoding)
        return try urlEncodedFormat(from: formURLEncoding.data.formData)
    }

    private func urlEncodedFormat(from formData: [String: String]) throws -> Data {
        let pairs = formData.map { "\($0)=\($1.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)" }.sorted()
        return pairs.joined(separator: "&").data(using: .utf8)!
    }
}

fileprivate struct FormURLEncoding: Encoder {
    fileprivate final class Data {
        private(set) var formData: [String: String] = [:]

        func encode(key codingKey: [CodingKey], value: String) throws {
            guard !codingKey.isEmpty else {
                throw EncodingError.invalidValue(value, .init(codingPath: codingKey,
                                                              debugDescription: "FormURLEncoding requires key/value pairs and cannot represent unkeyed standalone values",
                                                              underlyingError: nil))
            }

            // nested objects should be like thing[nestedVal]=newThing
            // multiple nesting is like thing[nested][thenNestedAgain]=thing
            // no real standard exists, PHP has done this forever
            // see: https://www.php.net/http_build_query
            let key = try codingKey.enumerated().reduce("") {
                if $1.offset == 0 {
                    return $0 + $1.element.stringValue
                }
                guard let encoded = "[\($1.element.stringValue)]".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
                    throw EncodingError.invalidValue(value, .init(codingPath: codingKey,
                                                                  debugDescription: "Unable to URL encode key: \($1.element.stringValue)",
                                                                  underlyingError: nil))
                }
                return $0 + encoded
            }
            formData[key] = value
        }
    }

    fileprivate var data: Data

    init(to encodedData: Data = Data()) {
        self.data = encodedData
    }

    var codingPath: [CodingKey] = []

    let userInfo: [CodingUserInfoKey : Any] = [:]

    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
        var container = FormURLKeyedEncoding<Key>(to: data)
        container.codingPath = codingPath
        return KeyedEncodingContainer(container)
    }

    func unkeyedContainer() -> UnkeyedEncodingContainer {
        var container = FormURLUnkeyedEncoding(to: data)
        container.codingPath = codingPath
        return container
    }

    func singleValueContainer() -> SingleValueEncodingContainer {
        var container = FormURLSingleValueEncoding(to: data)
        container.codingPath = codingPath
        return container
    }
}

fileprivate struct FormURLKeyedEncoding<Key: CodingKey>: KeyedEncodingContainerProtocol {

    private let data: FormURLEncoding.Data

    init(to data: FormURLEncoding.Data) {
        self.data = data
    }

    var codingPath: [CodingKey] = []

    mutating func encodeNil(forKey key: Key) throws {
        /* nil does not get encoded */
    }

    mutating func encode(_ value: Bool, forKey key: Key) throws {
        try data.encode(key: codingPath + [key], value: String(describing: value))
    }

    mutating func encode(_ value: String, forKey key: Key) throws {
        try data.encode(key: codingPath + [key], value: value)
    }

    mutating func encode(_ value: Double, forKey key: Key) throws {
        try data.encode(key: codingPath + [key], value: String(describing: value))
    }

    mutating func encode(_ value: Float, forKey key: Key) throws {
        try data.encode(key: codingPath + [key], value: String(describing: value))
    }

    mutating func encode(_ value: Int, forKey key: Key) throws {
        try data.encode(key: codingPath + [key], value: String(describing: value))
    }

    mutating func encode(_ value: Int8, forKey key: Key) throws {
        try data.encode(key: codingPath + [key], value: String(describing: value))
    }

    mutating func encode(_ value: Int16, forKey key: Key) throws {
        try data.encode(key: codingPath + [key], value: String(describing: value))
    }

    mutating func encode(_ value: Int32, forKey key: Key) throws {
        try data.encode(key: codingPath + [key], value: String(describing: value))
    }

    mutating func encode(_ value: Int64, forKey key: Key) throws {
        try data.encode(key: codingPath + [key], value: String(describing: value))
    }

    mutating func encode(_ value: UInt, forKey key: Key) throws {
        try data.encode(key: codingPath + [key], value: String(describing: value))
    }

    mutating func encode(_ value: UInt8, forKey key: Key) throws {
        try data.encode(key: codingPath + [key], value: String(describing: value))
    }

    mutating func encode(_ value: UInt16, forKey key: Key) throws {
        try data.encode(key: codingPath + [key], value: String(describing: value))
    }

    mutating func encode(_ value: UInt32, forKey key: Key) throws {
        try data.encode(key: codingPath + [key], value: String(describing: value))
    }

    mutating func encode(_ value: UInt64, forKey key: Key) throws {
        try data.encode(key: codingPath + [key], value: String(describing: value))
    }

    mutating func encode<T: Encodable>(_ value: T, forKey key: Key) throws {
        var formURLEncoding = FormURLEncoding(to: data)
        formURLEncoding.codingPath.append(key)
        try value.encode(to: formURLEncoding)
    }

    mutating func nestedContainer<NestedKey: CodingKey>(
        keyedBy keyType: NestedKey.Type,
        forKey key: Key) -> KeyedEncodingContainer<NestedKey> {
        var container = FormURLKeyedEncoding<NestedKey>(to: data)
        container.codingPath = codingPath + [key]
        return KeyedEncodingContainer(container)
    }

    mutating func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
        var container = FormURLUnkeyedEncoding(to: data)
        container.codingPath = codingPath + [key]
        return container
    }

    mutating func superEncoder() -> Encoder {
        let superKey = Key(stringValue: "super") ?? Key(intValue: 0)!
        return superEncoder(forKey: superKey)
    }

    mutating func superEncoder(forKey key: Key) -> Encoder {
        var formURLEncoding = FormURLEncoding(to: data)
        formURLEncoding.codingPath = codingPath + [key]
        return formURLEncoding
    }
}

fileprivate struct FormURLUnkeyedEncoding: UnkeyedEncodingContainer {
    enum UnkeyedEncodingError: Error {
        case noKeyFound
    }

    private let data: FormURLEncoding.Data

    init(to data: FormURLEncoding.Data) {
        self.data = data
    }

    var codingPath: [CodingKey] = []

    private(set) var count: Int = 0

    private mutating func nextIndexedKey() throws -> CodingKey {
        guard !codingPath.isEmpty,
              let nextCodingKey = IndexedCodingKey(intValue: count) else {
            throw UnkeyedEncodingError.noKeyFound
        }
        count += 1
        return nextCodingKey
    }

    private struct IndexedCodingKey: CodingKey {
        let intValue: Int?
        let stringValue: String

        init?(intValue: Int) {
            self.intValue = intValue
            stringValue = String(describing: intValue)
        }

        init?(stringValue: String) { nil }
    }

    mutating func encodeNil() throws {
        /* nil does not get encoded */
    }

    mutating func encode(_ value: Bool) throws {
        try data.encode(key: codingPath + [nextIndexedKey()], value: String(describing: value))
    }

    mutating func encode(_ value: String) throws {
        try data.encode(key: codingPath + [nextIndexedKey()], value: value)
    }

    mutating func encode(_ value: Double) throws {
        try data.encode(key: codingPath + [nextIndexedKey()], value: String(describing: value))
    }

    mutating func encode(_ value: Float) throws {
        try data.encode(key: codingPath + [nextIndexedKey()], value: String(describing: value))
    }

    mutating func encode(_ value: Int) throws {
        try data.encode(key: codingPath + [nextIndexedKey()], value: String(describing: value))
    }

    mutating func encode(_ value: Int8) throws {
        try data.encode(key: codingPath + [nextIndexedKey()], value: String(describing: value))
    }

    mutating func encode(_ value: Int16) throws {
        try data.encode(key: codingPath + [nextIndexedKey()], value: String(describing: value))
    }

    mutating func encode(_ value: Int32) throws {
        try data.encode(key: codingPath + [nextIndexedKey()], value: String(describing: value))
    }

    mutating func encode(_ value: Int64) throws {
        try data.encode(key: codingPath + [nextIndexedKey()], value: String(describing: value))
    }

    mutating func encode(_ value: UInt) throws {
        try data.encode(key: codingPath + [nextIndexedKey()], value: String(describing: value))
    }

    mutating func encode(_ value: UInt8) throws {
        try data.encode(key: codingPath + [nextIndexedKey()], value: String(describing: value))
    }

    mutating func encode(_ value: UInt16) throws {
        try data.encode(key: codingPath + [nextIndexedKey()], value: String(describing: value))
    }

    mutating func encode(_ value: UInt32) throws {
        try data.encode(key: codingPath + [nextIndexedKey()], value: String(describing: value))
    }

    mutating func encode(_ value: UInt64) throws {
        try data.encode(key: codingPath + [nextIndexedKey()], value: String(describing: value))
    }

    mutating func encode<T: Encodable>(_ value: T) throws {
        var formURLEncoding = FormURLEncoding(to: data)
        formURLEncoding.codingPath = codingPath + [try nextIndexedKey()]
        try value.encode(to: formURLEncoding)
    }

    mutating func nestedContainer<NestedKey: CodingKey>(
        keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> {
        var container = FormURLKeyedEncoding<NestedKey>(to: data)
        container.codingPath = codingPath + [try! nextIndexedKey()]
        return KeyedEncodingContainer(container)
    }

    mutating func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        var container = FormURLUnkeyedEncoding(to: data)
        container.codingPath = codingPath + [try! nextIndexedKey()]
        return container
    }

    mutating func superEncoder() -> Encoder {
        var formURLEncoding = FormURLEncoding(to: data)
        formURLEncoding.codingPath.append(try! nextIndexedKey())
        return formURLEncoding
    }
}

fileprivate struct FormURLSingleValueEncoding: SingleValueEncodingContainer {
    private let data: FormURLEncoding.Data

    init(to data: FormURLEncoding.Data) {
        self.data = data
    }

    var codingPath: [CodingKey] = []

    mutating func encodeNil() throws {
        /* nil does not get encoded */
    }

    mutating func encode(_ value: Bool) throws {
        try data.encode(key: codingPath, value: String(describing: value))
    }

    mutating func encode(_ value: String) throws {
        try data.encode(key: codingPath, value: value)
    }

    mutating func encode(_ value: Double) throws {
        try data.encode(key: codingPath, value: String(describing: value))
    }

    mutating func encode(_ value: Float) throws {
        try data.encode(key: codingPath, value: String(describing: value))
    }

    mutating func encode(_ value: Int) throws {
        try data.encode(key: codingPath, value: String(describing: value))
    }

    mutating func encode(_ value: Int8) throws {
        try data.encode(key: codingPath, value: String(describing: value))
    }

    mutating func encode(_ value: Int16) throws {
        try data.encode(key: codingPath, value: String(describing: value))
    }

    mutating func encode(_ value: Int32) throws {
        try data.encode(key: codingPath, value: String(describing: value))
    }

    mutating func encode(_ value: Int64) throws {
        try data.encode(key: codingPath, value: String(describing: value))
    }

    mutating func encode(_ value: UInt) throws {
        try data.encode(key: codingPath, value: String(describing: value))
    }

    mutating func encode(_ value: UInt8) throws {
        try data.encode(key: codingPath, value: String(describing: value))
    }

    mutating func encode(_ value: UInt16) throws {
        try data.encode(key: codingPath, value: String(describing: value))
    }

    mutating func encode(_ value: UInt32) throws {
        try data.encode(key: codingPath, value: String(describing: value))
    }

    mutating func encode(_ value: UInt64) throws {
        try data.encode(key: codingPath, value: String(describing: value))
    }

    mutating func encode<T: Encodable>(_ value: T) throws {
        try value.encode(to: FormURLEncoding(to: data))
    }
}
