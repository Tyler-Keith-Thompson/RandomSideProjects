import Parsing
import Foundation

typealias FWS = FoldableWhitespace

enum FoldableWhitespace {
    @ParserBuilder static func parser() -> some Parser<Substring, Substring?> {
        Optionally { CharacterSet.whitespacesAndNewlines }
    }
}
