import Foundation
import Parsing

public typealias AddrSpec = AddressSpecification

public enum AddressSpecification {
    static func parser() -> some Parser<Substring, (localPart: Token, domainPart: Token)> {
        let localPartParser = Parse {
            OneOf {
                QuotedString.parser()
                DotAtom.parser()
            }
        }

        let IPv4LiteralParser = Parse {
            "["
            IPv4.parser()
            "]"
        }

        let IPv6LiteralParser = Parse {
            "[IPv6:"
            IPv6.parser()
            "]"
        }

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
