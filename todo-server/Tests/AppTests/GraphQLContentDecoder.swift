//
//  File.swift
//  
//
//  Created by Tyler Thompson on 6/13/21.
//

import XCTVapor

struct GraphQLContentDecoder: ContentDecoder {
    let queryName: String

    private static var decoder: JSONDecoder { JSONDecoder() }
    func decode<D>(_ decodable: D.Type, from body: ByteBuffer, headers: HTTPHeaders) throws -> D where D : Decodable {
        try Self.decoder.decode(D.self, from: body.extractingJSONContainer(named: "data").extractingJSONContainer(named: queryName))
    }
}
