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
        let email = try Email.parser().parse(emailStr)
        mailbox = email.mailbox
        localPart = email.localPart
        domainPart = email.domainPart
    }

    init(localPart: String, domainPart: String, mailbox: String) {
        self.localPart = localPart
        self.domainPart = domainPart
        self.mailbox = mailbox
    }
}

extension Email {
    @inlinable public static func parser() -> some Parser<Substring, Email> {
        EmailParser()
    }

    public struct EmailParser: Parser {
        public init() { }
        
        public func parse(_ input: inout Substring) throws -> Email {
            let mailbox = "\(input)"
            let (local, domain) = try Mailbox.parser().parse(&input)

            if local.count + domain.count + 1 /*@*/ > 254 {
                throw ParserError.emailTooLong
            }

            return Email(localPart: local, domainPart: domain, mailbox: mailbox)
        }
    }
}
