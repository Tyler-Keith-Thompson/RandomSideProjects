import Foundation
import Parsing

typealias FQDN = FullyQualifiedDomainName

struct FullyQualifiedDomainName: Parser {
    enum ParserError: Error {
        case invalidSubdomain
        case invalidTopLevelDomain
        case emptyAtom
        case invalidAtom
        case atomTooLong
        case invalidCharacter
    }

    static func parser() -> some Parser<Substring, Token> {
        Self()
    }

    func parse(_ input: inout Substring) throws -> Token {
        let dotAtomToken = try DotAtom.parser().parse(&input)
        guard case .dotAtom(let dotAtomTokens) = dotAtomToken.semanticOnly else {
            throw ParserError.invalidAtom
        }
        let aTexts: [String] = dotAtomTokens.map(\.description)

        guard let tld = aTexts.last else { throw ParserError.emptyAtom }

        if tld.lazy.flatMap({ $0.unicodeScalars }).allSatisfy({ CharacterSet.decimalDigits.contains($0) }) {
            throw ParserError.invalidTopLevelDomain
        }

        try aTexts.forEach {
            if $0.isEmpty {
                throw ParserError.invalidSubdomain
            } else if $0.prefix(1) == "-" || $0.suffix(1) == "-" {
                throw ParserError.invalidAtom
            } else if $0.count > 63 {
                throw ParserError.atomTooLong
            }
            guard CharacterSet($0.unicodeScalars).subtracting(CharacterSet.alphanumerics.union(["-"])).isEmpty else {
                throw ParserError.invalidCharacter
            }
        }

        return dotAtomToken
    }
}
