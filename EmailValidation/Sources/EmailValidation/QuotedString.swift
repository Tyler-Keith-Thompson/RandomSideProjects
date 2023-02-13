import Foundation
import Parsing

enum QuotedString {
    private static let escape = Parse {
        "\\"
        Prefix(1)
    }.map { "\\\($0)" }

    static func parser() -> some Parser<Substring, String> {
        Parse {
            CFWS.parser()
            "\""
            Many(into: "") { string, fragment in
                string += fragment
            } element: {
                OneOf {
                    Prefix(1...) { $0 != "\"" && $0 != "\\" }.map(.string)

                    escape
                }
            } terminator: {
                "\""
            }
            CFWS.parser()
        }
        .map { "\($0.0 ?? "")\"\($0.1)\"\($0.2 ?? "")" }
    }
}
