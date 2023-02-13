import Foundation
import Parsing

struct DotAtom: Parser {
    enum ParserError: Error {
        case emptyAtom
        case invalidAtom
        case atomTooLong
    }

    static func parser() -> some Parser<Substring, Token> {
        Self()
    }

    func parse(_ input: inout Substring) throws -> Token {
        let atoms = try Many(into: [(lcfws: [Token], aText: Token, rcfws: [Token])]()) {
            $0.append((lcfws: $1.0, aText: $1.1, rcfws: $1.2))
        } element: {
            CFWS.parser()
            CharacterSet.dotAtomAText
                .map { Token.aText($0) }
            CFWS.parser()
        } separator: {
            "."
        }.parse(&input)

        guard !atoms.isEmpty else { throw ParserError.emptyAtom }

        try atoms.lazy
            .map(\.aText.description)
            .forEach {
                if $0.isEmpty {
                    throw ParserError.emptyAtom
                } else if $0.count > 63 {
                    throw ParserError.atomTooLong
                }
            }

        return .dotAtom(atoms.map { .atom($0.lcfws + [$0.aText] + $0.rcfws) })
    }
}

extension CharacterSet {
    static let dotAtomAText = {
        CharacterSet.alphanumerics.union(CharacterSet.symbols)
        .union(["!", "#", "%", "&", "'", "*", "-", "/", "?", "_", "{", "}"]) // additional characters not in symbols but that are valid atom content
        // Control characters shouldn't be in either set, but just to be sure, get rid of them.
        .subtracting(CharacterSet.controlCharacters)
        // Disallowed atom symbols
        .subtracting(["@", "(", ")", "<", ">", ".", "\"", "[", "]", ","])
    }()
}
