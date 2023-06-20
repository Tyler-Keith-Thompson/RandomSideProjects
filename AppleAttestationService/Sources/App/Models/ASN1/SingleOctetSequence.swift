//
//  SingleOctetSequence.swift
//  
//
//  Created by Tyler Thompson on 6/19/23.
//

import Foundation
import SwiftASN1

struct SingleOctetSequence: DERParseable {
    init(derEncoded rootNode: ASN1Node) throws {
        octet = try DER.sequence(rootNode, identifier: rootNode.identifier) { nodes in
            guard let node = nodes.next() else {
                throw ASN1Error.invalidASN1Object(reason: "Empty sequence! Expected single octet")
            }
            return try DER.sequence(node, identifier: node.identifier, {
                try ASN1OctetString(derEncoded: &$0)
            })
        }
    }

    let octet: ASN1OctetString
}
