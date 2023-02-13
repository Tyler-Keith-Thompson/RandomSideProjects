import Foundation
import Parsing

enum IPv4 {
    static func parser() -> some Parser<Substring, Token> {
        Parse {
            UInt8.parser()
            "."
            UInt8.parser()
            "."
            UInt8.parser()
            "."
            UInt8.parser()
        }.map { Token.IPv4Literal($0, $1, $2, $3) }
    }
}
