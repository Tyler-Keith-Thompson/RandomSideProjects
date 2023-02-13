import Parsing
import Foundation

public struct SemanticEmail {
    private let localPartToken: Token
    private let domainPartToken: Token

    public var localPart: String {
        localPartToken.description
    }

    public var domainPart: String {
        domainPartToken.description
    }

    public let mailbox: String

    @inlinable public var address: String {
        "\(localPart)@\(domainPart)"
    }

    init(localPart: Token, domainPart: Token, mailbox: String) {
        localPartToken = localPart.semanticOnly
        domainPartToken = domainPart.semanticOnly
        self.mailbox = mailbox
    }
}
