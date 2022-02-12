import XCTest
@testable import FormURLCoder

final class FormURLEncoderTests: XCTestCase {
    func testSimpleKeyValueCanFormEncode() throws {
        struct TypeToEncode: Encodable {
            let firstKey = "value"
            let secondKey = "some new value with $ weird chars that need to be encoded"
        }

        let type = TypeToEncode()

        let expected = "firstKey=\(type.firstKey.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)&secondKey=\(type.secondKey.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)"

        let data = try FormURLEncoder().encode(type)

        XCTAssertEqual(String(data: data, encoding: .utf8), expected)
    }

    func testUnkeyedTypeCannotEncode() throws {
        struct Reasonable: Encodable {
            let key = "value"
        }

        XCTAssertThrowsError(try FormURLEncoder().encode([Reasonable()]))
    }

    func testSingleValueTypeCannotEncode() throws {
        XCTAssertThrowsError(try FormURLEncoder().encode("No key"))
    }

    func testKeyedArrayWithSingleValuesCanDecode() throws {
        struct FirstType: Encodable {
            let all = ["first", "second", "third"]
        }

        let type = FirstType()

        let first = try XCTUnwrap("all[0]=first".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed))
        let second = try XCTUnwrap("all[1]=second".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed))
        let third = try XCTUnwrap("all[2]=third".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed))

        let expected = [first, second, third].joined(separator: "&")

        let data = try FormURLEncoder().encode(type)

        XCTAssertEqual(String(data: data, encoding: .utf8), expected)
    }

    func testKeyedArrayWithKeyedValuesCanDecode() throws {
        struct FirstType: Encodable {
            let all = [Nested(key: "first"), Nested(key: "second"), Nested(key: "third")]
        }

        struct Nested: Encodable {
            let key: String
        }

        let type = FirstType()

        let first = try XCTUnwrap("all[0][key]=first".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed))
        let second = try XCTUnwrap("all[1][key]=second".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed))
        let third = try XCTUnwrap("all[2][key]=third".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed))

        let expected = [first, second, third].joined(separator: "&")

        let data = try FormURLEncoder().encode(type)

        XCTAssertEqual(String(data: data, encoding: .utf8), expected)
    }
}
