import Parsing
import Foundation

typealias CFWS = CommentsAndFoldableWhitespace

struct CommentsAndFoldableWhitespace: Parser {
    static func parser() -> some Parser<Substring, String?> {
        Self()
    }

    func parse(_ input: inout Substring) throws -> String? {
        try Parse {
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
        .parse(&input)
    }
}
