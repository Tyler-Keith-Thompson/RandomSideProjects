import Parsing
import Foundation

typealias FWS = FoldableWhitespace

struct FoldableWhitespace: Parser {
    static func parser() -> some Parser<Substring, Substring?> {
        Self()
    }

    func parse(_ input: inout Substring) throws -> Substring? {
        Parse {
            Optionally { CharacterSet.whitespacesAndNewlines }
        }.parse(&input)
    }
}
