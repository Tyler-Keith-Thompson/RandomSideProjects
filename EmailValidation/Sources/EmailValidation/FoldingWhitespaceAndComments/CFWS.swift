import Parsing
import Foundation

typealias CFWS = CommentsAndFoldableWhitespace

enum CommentsAndFoldableWhitespace {
    static func parser() -> some Parser<Substring, String?> {
        Parse {
            FWS.parser()
            Optionally { Comment.parser() }
            FWS.parser()
        }
        .map {
            guard let comment = $0.1 else {
                return nil
            }
            return "\($0.0 ?? "")\(comment)\($0.2 ?? "")"
        }
    }
}
