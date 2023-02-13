import Foundation
import Parsing

enum IPv4 {
    @ParserBuilder static func parser() -> some Parser<Substring, (UInt8, UInt8, UInt8, UInt8)> {
        UInt8.parser()
        "."
        UInt8.parser()
        "."
        UInt8.parser()
        "."
        UInt8.parser()
    }
}
