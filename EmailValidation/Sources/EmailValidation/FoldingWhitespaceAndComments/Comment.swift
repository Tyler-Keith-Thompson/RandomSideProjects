import Foundation
import Parsing

enum Comment {
    static func stringParser() -> some Parser<Substring, Substring> {
        Parse {
            "("
            Many(into: Substring("(")) { string, fragment in
                string += fragment
            } element: {
                OneOf {
                    Prefix(1...) { $0 != "(" && $0 != ")" }

                    Lazy { Self.stringParser() }
                }
            } terminator: {
                ")"
            }
        }
        .map { $0 + ")" }
        .eraseToAnyParser()
    }
    static func parser() -> some Parser<Substring, Token> {
        stringParser()
            .map { .comment($0) }
    }
}
