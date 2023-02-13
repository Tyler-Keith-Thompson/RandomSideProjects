import Foundation
import Parsing

public typealias NameAddr = NameAddress

public enum NameAddress {
    static func parser() -> some Parser<Substring, (localPart: String, domainPart: String)> {
        let angleAddrParser = Parse {
            CFWS.parser()
            "<"
            AddrSpec.parser()
            ">"
            CFWS.parser()
        }

        return Parse {
            OneOf {
                QuotedString.parser()
                CharacterSet.dotAtomAText
                    .union(CharacterSet.whitespaces)
                    .union(["."])
                    .map(.string)
            }
            angleAddrParser
        }.map { $1.1 }
    }
}
