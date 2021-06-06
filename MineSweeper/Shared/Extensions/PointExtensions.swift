//
//  PointExtensions.swift
//  MineSweeper
//
//  Created by Tyler Thompson on 6/1/21.
//

import Foundation

extension NSPoint {
    func moving(_ direction: Direction) -> NSPoint {
        switch direction {
            case .northwest: return NSPoint(x: x-1, y: y+1)
            case .north: return NSPoint(x: x, y: y+1)
            case .northeast: return NSPoint(x: x+1, y: y+1)
            case .west: return NSPoint(x: x-1, y: y)
            case .east: return NSPoint(x: x+1, y: y)
            case .southwest: return NSPoint(x: x-1, y: y-1)
            case .south: return NSPoint(x: x, y: y-1)
            case .southeast: return NSPoint(x: x+1, y: y-1)
        }
    }
}

extension NSPoint: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }
}
