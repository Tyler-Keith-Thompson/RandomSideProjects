import Foundation
import Parsing

public typealias AddrSpec = AddressSpecification

public enum AddressSpecification {
    static func parser() -> some Parser<Substring, (localPart: String, domainPart: String)> {
        let localPartParser = Parse {
            OneOf {
                QuotedString.parser()
                DotAtom.parser().map { $0.lazy.map { "\($0.lComment ?? "")\($0.atom)\($0.rComment ?? "")" }.joined(separator: ".") }
            }
        }

        let IPv4LiteralParser = Parse {
            "["
            IPv4.parser()
            "]"
        }.map { "[\($0).\($1).\($2).\($3)]" }

        let IPv6LiteralParser = Parse {
            "[IPv6:"
            IPv6.parser()
            "]"
        }.map { "[IPv6:\($0.string)]" }

        let domainLiteralParser = Parse {
            OneOf {
                IPv4LiteralParser
                IPv6LiteralParser
            }
        }

        let domainPartParser = Parse {
            OneOf {
                domainLiteralParser
                FQDN.parser()
            }
        }

        return Parse {
            localPartParser
            "@"
            domainPartParser
        }.map { (localPart: $0.0, domainPart: $0.1) }
    }
}
