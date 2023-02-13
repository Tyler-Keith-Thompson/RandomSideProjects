import Foundation
import Parsing

struct DotAtom: Parser {
    enum ParserError: Error {
        case emptyAtom
        case invalidAtom
        case atomTooLong
    }

    static func parser() -> some Parser<Substring, [(lComment: String?, atom: Substring, rComment: String?)]> {
        Self()
    }

    func parse(_ input: inout Substring) throws -> [(lComment: String?, atom: Substring, rComment: String?)] {
        let atoms = try Many(into: [(lComment: String?, atom: Substring, rComment: String?)]()) {
            $0.append($1)
        } element: {
            CFWS.parser()
            CharacterSet.dotAtomAText
            CFWS.parser()
        } separator: {
            "."
        }.parse(&input)

        guard !atoms.isEmpty else { throw ParserError.emptyAtom }

        try atoms.lazy
            .map(\.atom)
            .forEach {
                if $0.isEmpty {
                    throw ParserError.emptyAtom
                } else if $0.count > 63 {
                    throw ParserError.atomTooLong
                }
            }

        return atoms
    }
}

extension CharacterSet {
    static let dotAtomAText = {
        CharacterSet.alphanumerics.union(CharacterSet.symbols)
        .union(["!", "#", "%", "&", "'", "*", "-", "/", "?", "_", "{", "}"]) // additional characters not in symbols but that are valid atom content
        // Control characters shouldn't be in either set, but just to be sure, get rid of them.
        .subtracting(CharacterSet.controlCharacters)
        // Disallowed atom symbols
        .subtracting(["@", "(", ")", "<", ">", ".", "\"", "[", "]"])
    }()
}
