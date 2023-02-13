import Foundation
import Parsing

enum QuotedString {
    private static let escape = Parse {
        "\\"
        Prefix(1)
    }.map { "\\\($0)" }

    static func parser() -> some Parser<Substring, Token> {
        Parse {
            CFWS.parser()
            "\""
            Many(into: "") { qText, fragment in
                qText += fragment
            } element: {
                OneOf {
                    Prefix(1...) { $0 != "\"" && $0 != "\\" }.map(.string)

                    escape
                }
            } terminator: {
                "\""
            }.map { Token.qText($0) }
            CFWS.parser()
        }
        .map { .quotedString([$0.0, [$0.1], $0.2].flatMap { $0 }) }
    }
}
