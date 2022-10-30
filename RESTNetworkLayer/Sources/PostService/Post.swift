//
//  File.swift
//  
//
//  Created by Tyler Thompson on 10/30/22.
//

import Foundation

public struct Post: Decodable {
    let userId: Int
    let id: Int
    let title: String
    let content: String
}
