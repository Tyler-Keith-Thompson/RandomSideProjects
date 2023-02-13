import Foundation
import Parsing

public enum Mailbox {
    @ParserBuilder static func parser() -> some Parser<Substring, (localPart: String, domainPart: String)> {
        OneOf {
            NameAddr.parser()
            AddrSpec.parser()
        }
    }
}
