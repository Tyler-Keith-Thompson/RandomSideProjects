//
//  Cell.swift
//  MineSweeperTests
//
//  Created by Tyler Thompson on 6/1/21.
//

import Foundation

struct Cell: Equatable {
    static func == (lhs: Cell, rhs: Cell) -> Bool {
        lhs.coordinate == rhs.coordinate
            && lhs.isSelected == rhs.isSelected
            && lhs.isMine == rhs.isMine
    }

    let coordinate: NSPoint
    let board: Board
    var isSelected: Bool = false
    var isMine: Bool = false
    var numberOfSurroundingMines: Int { 1 }
}
