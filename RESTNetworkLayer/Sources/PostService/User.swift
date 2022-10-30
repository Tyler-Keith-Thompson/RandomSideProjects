//
//  File.swift
//  
//
//  Created by Tyler Thompson on 10/30/22.
//

import Foundation

final class User: Decodable {
    static var shared = User()

    var accessToken = ""
    var refreshToken = ""
    
    private init() { }
}
