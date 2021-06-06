//
//  BoardViewTests.swift
//  MineSweeperTests
//
//  Created by Tyler Thompson on 6/1/21.
//

import Foundation
import XCTest
import ViewInspector

@testable import MineSweeper

extension BoardView: Inspectable { }

final class BoardViewTests: XCTestCase {
    func testBoardView() throws {
        let height = Int.random(in: 1...3)
        let width = Int.random(in: 1...3)
        let board = Board(width: width, height: height)
        let view = try BoardView(board: board).inspect()

        let scrollView = try view.find(ViewType.ScrollView.self)
        let columns = try scrollView.vStack().forEach(0)
        XCTAssertEqual(columns.count, height)
        try columns.enumerated().forEach { column in
            XCTAssertNoThrow(try columns.find(ViewType.ForEach.self))
            let rows = try columns.hStack(column.offset).forEach(0)
            XCTAssertEqual(rows.count, width)
            try rows.enumerated().forEach { row in
                XCTAssertNoThrow(try row.element.view(CellView.self))
                let cellView = try row.element.view(CellView.self).actualView()
                XCTAssertEqual(cellView.cell, board.grid[NSPoint(x: row.offset, y: column.offset)])
            }
        }
    }
}
