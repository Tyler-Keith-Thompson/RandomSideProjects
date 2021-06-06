//
//  Board.swift
//  MineSweeper
//
//  Created by Tyler Thompson on 6/1/21.
//

import Foundation

final class Board {
    let height: Int
    let width: Int

    var grid = [NSPoint: Cell]()
    init(width: Int, height: Int) {
        self.height = height
        self.width = width
        (0..<height).map { y in
            (0..<width).map { x in
                NSPoint(x: x, y: y)
            }
        }
        .flatMap { $0 }
        .forEach {
            grid[$0] = Cell(coordinate: $0, board: self)
        }
    }
}
