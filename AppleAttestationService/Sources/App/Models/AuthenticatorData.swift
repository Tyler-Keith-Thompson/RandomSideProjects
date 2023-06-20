//
//  File.swift
//  
//
//  Created by Tyler Thompson on 6/19/23.
//

import Foundation

struct AuthenticatorData: Equatable, Decodable {
    let bytes: Data

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        bytes = try container.decode(Data.self)
    }

    var rpID: Data {
        bytes[0..<32]
    }

    var counter: Int32 {
        bytes[33..<37].reduce(0) { value, byte in
            value << 8 | Int32(byte) // UInt32 ?
        }
    }

    var aaguid: AAGUID? {
        AAGUID(bytes: bytes[37..<53])
    }

    enum AAGUID: String, CaseIterable {
        case appAttest = "appattest"
        case appAttestDevelop = "appattestdevelop"

        init?(bytes: Data) {
            if let id = AAGUID.allCases.first(where: { bytes == $0.bytes }) {
                self = id
            } else {
                return nil
            }
        }

        var bytes: Data {
            let data = Data(rawValue.utf8)
            switch self {
            case .appAttestDevelop:
                return data
            case .appAttest:
                return data + Data(repeatElement(0x00, count: 7))
            }
        }
    }

    var credentialID: Data {
        let length = bytes[53..<55].reduce(0) { value, byte in
            value << 8 | UInt16(byte)
        }
        return bytes[55..<(55 + length)]
    }
}
