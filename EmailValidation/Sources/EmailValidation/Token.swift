indirect enum Token: CustomStringConvertible {
    case comment(Substring)
    case foldableWhiteSpace(Substring)
    case aText(Substring)
    case atom([Token])
    case dotAtom([Token])
    case quotedString([Token])
    case qText(Substring)
    case IPv4Literal(UInt8, UInt8, UInt8, UInt8)
    case IPv6Literal(IPv6)
    case ignored

    var description: String {
        switch self {
            case .comment(let cText): return String(cText)
            case .foldableWhiteSpace(let wsp): return String(wsp)
            case .aText(let aText): return String(aText)
            case .atom(let tokens): return tokens.map(\.description).joined()
            case .dotAtom(let tokens): return tokens.map(\.description).joined(separator: ".")
            case .quotedString(let tokens): return tokens.map(\.description).joined()
            case .qText(let qText): return "\"\(qText)\""
            case .IPv4Literal(let octet1, let octet2, let octet3, let octet4): return "[\(octet1).\(octet2).\(octet3).\(octet4)]"
            case .IPv6Literal(let ipv6): return "[IPv6:\(ipv6.string)]"
            case .ignored: return String()
        }
    }

    var semanticOnly: Token {
        switch self {
            case .comment: return .ignored
            case .foldableWhiteSpace: return .ignored
            case .aText: return self
            case .atom(let tokens): return .atom(tokens.map(\.semanticOnly))
            case .dotAtom(let tokens): return .dotAtom(tokens.map(\.semanticOnly))
            case .quotedString(let tokens): return .quotedString(tokens.map(\.semanticOnly))
            case .qText: return self
            case .IPv4Literal: return self
            case .IPv6Literal: return self
            case .ignored: return self
        }
    }
}
