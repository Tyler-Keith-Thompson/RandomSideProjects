import Foundation
import Parsing

struct IPv6 {
    enum ParserError: Error {
        case shorthandInvalid
        case tooManyShorthandNotations
        case tooManyBlocks
    }

    static func parser() -> some Parser<Substring, IPv6> {
        IPv6Parser()
    }

    enum GroupContent {
        case block(UInt16)
        case shorthand

        var isShorthand: Bool {
            if case .shorthand = self {
                return true
            }
            return false
        }
    }

    let blocks: [UInt16]
    let longestSubsequence: [(offset: Int, element: UInt16)]?

    var string: String {
        blocks.enumerated().reduce(into: [String]()) { arr, el in
            if let startSubsequenceOffset = longestSubsequence?.first?.offset,
               let endSubsequenceOffset = longestSubsequence?.last?.offset,
               startSubsequenceOffset != endSubsequenceOffset {
                if el.offset == startSubsequenceOffset && el.offset == 0 {
                    arr.append("")
                } else if el.offset == endSubsequenceOffset {
                    arr.append("")
                } else if el.offset < startSubsequenceOffset || el.offset > endSubsequenceOffset {
                    arr.append(String(el.element, radix: 16, uppercase: true))
                }
            } else {
                arr.append(String(el.element, radix: 16, uppercase: true))
            }
        }.joined(separator: ":")
    }

    init(groups: [GroupContent]) throws {
        if groups.filter({ $0.isShorthand }).count > 1 {
            throw ParserError.tooManyShorthandNotations
        }
        guard groups.count <= 8 else { throw ParserError.tooManyBlocks }
        if groups.count == 8 {
            blocks = try groups.map {
                guard case .block(let block) = $0 else {
                    throw ParserError.shorthandInvalid
                }
                return block
            }
        } else {
            let expandedShorthand = 8 - groups.count
            blocks = groups.map {
                guard case .block(let block) = $0 else {
                    return (0...expandedShorthand).map { _ in UInt16(0) }
                }
                return [ block ]
            }.flatMap { $0 }
        }
        longestSubsequence = Array(blocks.enumerated())
            .lazy
            .chunked(by: { $0.element == 0 && $1.element == 0 })
            .filter { $0.allSatisfy { $0.element == 0 } }
            .max(by: { $0.count > $1.count })
            .map(Array.init)
    }

    struct IPv6Parser: Parser {
        func parse(_ input: inout Substring) throws -> IPv6 {
            let groups = try Many(into: [GroupContent]()) {
                if let block = $1 {
                    $0.append(.block(block))
                } else if $0.last?.isShorthand != true {
                    $0.append(.shorthand)
                }
            } element: {
                Optionally { UInt16.parser(radix: 16) }
            } separator: {
                ":"
            }
            .parse(&input)

            return try IPv6(groups: groups)
        }
    }
}
