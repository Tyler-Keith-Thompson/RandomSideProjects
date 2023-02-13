import Foundation
import Parsing

public enum Mailbox {
    @ParserBuilder static func parser() -> some Parser<Substring, (localPart: Token, domainPart: Token)> {
        OneOf {
            AddrSpec.parser()
            NameAddr.parser()
        }
    }
}
