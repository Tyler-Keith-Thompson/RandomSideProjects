import Foundation
import Parsing

enum Comment {
    static func parser() -> some Parser<Substring, String> {
        Parse {
            "("
            Many(into: "") { string, fragment in
                string += fragment
            } element: {
                OneOf {
                    Prefix(1...) { $0 != "(" && $0 != ")" }.map(String.init)

                    Lazy { Self.parser() }
                }
            } terminator: {
                ")"
            }
        }
        .map { "(\($0))" }
        .eraseToAnyParser()
    }
}
