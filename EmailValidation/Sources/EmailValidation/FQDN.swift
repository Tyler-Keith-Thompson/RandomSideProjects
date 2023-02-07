import Foundation
import Parsing

typealias FQDN = FullyQualifiedDomainName

struct FullyQualifiedDomainName: Parser {
    enum ParserError: Error {
        case invalidSubLevelDomain
        case invalidTopLevelDomain
        case emptyAtom
        case invalidAtom
        case atomTooLong
        case invalidCharacter
    }

    static func parser() -> some Parser<Substring, String> {
        Self()
    }

    func parse(_ input: inout Substring) throws -> String {
        let atoms = try DotAtom.parser().parse(&input)

        guard let tld = atoms.last?.atom, !tld.isEmpty else { throw ParserError.emptyAtom }

        if tld.flatMap({ $0.unicodeScalars }).allSatisfy({ CharacterSet.decimalDigits.contains($0) }) {
            throw ParserError.invalidTopLevelDomain
        }

        try atoms.map(\.atom).forEach {
            if $0.isEmpty {
                throw ParserError.invalidSubLevelDomain
            } else if $0.prefix(1) == "-" || $0.suffix(1) == "-" {
                throw ParserError.invalidAtom
            } else if $0.count > 63 {
                throw ParserError.atomTooLong
            }
            let allValidChars = $0.flatMap(\.unicodeScalars).allSatisfy { CharacterSet.alphanumerics.union(["-"]).contains($0) }
            guard allValidChars else { throw ParserError.invalidCharacter }
        }

        return atoms.lazy.map { "\($0.lComment ?? "")\($0.atom)\($0.rComment ?? "")" }.joined(separator: ".")
    }
}
