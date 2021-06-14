//
//  File.swift
//  
//
//  Created by Tyler Thompson on 6/13/21.
//

import XCTVapor

extension ByteBuffer {
    func extractingJSONContainer(named containerName: String) throws -> Data {
        let data = Data(buffer: self)
        let json = try JSONSerialization.jsonObject(with: data, options: []) as? [AnyHashable: Any]
        return try JSONSerialization.data(withJSONObject: try XCTUnwrap(json?[containerName]), options: [])
    }
}

extension Data {
    func extractingJSONContainer(named containerName: String) throws -> Data {
        let json = try JSONSerialization.jsonObject(with: self, options: []) as? [AnyHashable: Any]
        return try JSONSerialization.data(withJSONObject: try XCTUnwrap(json?[containerName]), options: [])
    }
}
