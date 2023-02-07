//
//  Email.swift
//  
//
//  Created by Tyler Thompson on 2/4/23.
//

import Foundation
import Parsing
import Algorithms

public struct Email {
    enum ParserError: Error {
        case emailTooLong
    }

    public let localPart: String
    public let domainPart: String
    public let mailbox: String
    @inlinable public var address: String {
        "\(localPart)@\(domainPart)"
    }

    public init(_ emailStr: String) throws {
        mailbox = emailStr
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
        }.map { "\($0).\($1).\($2).\($3)" }

        let IPv6LiteralParser = Parse {
            "[IPv6:"
            IPv6.parser()
            "]"
        }.map(\.string)

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

        let addrSpecParser = Parse {
            localPartParser
            "@"
            domainPartParser
        }

        let nameAddrParser = Parse {
            OneOf {
                QuotedString.parser()
                CharacterSet.dotAtomAText
                    .union(CharacterSet.whitespaces)
                    .union(["."])
                    .map(.string)
            }
            Optionally { Comment.parser() }
            Optionally { CharacterSet.whitespaces }
            "<"
            addrSpecParser
            ">"
        }.map { $0.3 }

        let mailboxParser = Parse {
            OneOf {
                nameAddrParser
                addrSpecParser
            }
        }
        
        let (local, domain) = try mailboxParser.parse(emailStr)
        localPart = local
        domainPart = domain

        if local.count + domain.count + 1 /*@*/ > 254 {
            throw ParserError.emailTooLong
        }
    }
}
