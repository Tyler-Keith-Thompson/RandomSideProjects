import Parsing
import Foundation

typealias CFWS = CommentsAndFoldableWhitespace

enum CommentsAndFoldableWhitespace {
    static func parser() -> some Parser<Substring, [Token]> {
        Parse {
            FWS.parser()
            Optionally { Comment.parser() }
            FWS.parser()
        }
        .map { [ $0, $1, $2].compactMap { $0 } }
    }
}
