//
//  BoardTests.swift
//  MineSweeperTests
//
//  Created by Tyler Thompson on 6/1/21.
//

import Foundation
import XCTest

@testable import MineSweeper

final class BoardTests: XCTestCase {
    func testCreatingNewBoard() {
        let board = Board(width: 2, height: 2)
        XCTAssertEqual(board.grid[.zero], Cell(coordinate: .zero, board: board, isSelected: false))
        XCTAssertNil(board.grid[.zero.moving(.west)])
        XCTAssertNil(board.grid[.zero.moving(.southwest)])
        XCTAssertNil(board.grid[.zero.moving(.south)])
        XCTAssertNil(board.grid[.zero.moving(.southeast)])
        XCTAssertEqual(board.grid[.zero.moving(.east)], Cell(coordinate: .zero.moving(.east), board: board, isSelected: false))
        XCTAssertNil(board.grid[.zero.moving(.east).moving(.east)])
        XCTAssertNil(board.grid[.zero.moving(.east).moving(.southwest)])
        XCTAssertNil(board.grid[.zero.moving(.east).moving(.south)])
        XCTAssertNil(board.grid[.zero.moving(.east).moving(.southeast)])
        XCTAssertEqual(board.grid[.zero.moving(.north)], Cell(coordinate: .zero.moving(.north), board: board, isSelected: false))
        XCTAssertNil(board.grid[.zero.moving(.north).moving(.west)])
        XCTAssertNil(board.grid[.zero.moving(.north).moving(.northwest)])
        XCTAssertNil(board.grid[.zero.moving(.north).moving(.north)])
        XCTAssertNil(board.grid[.zero.moving(.north).moving(.northeast)])
        XCTAssertEqual(board.grid[.zero.moving(.north).moving(.east)], Cell(coordinate: .zero.moving(.north).moving(.east), board: board, isSelected: false))
        XCTAssertNil(board.grid[.zero.moving(.north).moving(.east).moving(.east)])
        XCTAssertNil(board.grid[.zero.moving(.north).moving(.east).moving(.northwest)])
        XCTAssertNil(board.grid[.zero.moving(.north).moving(.east).moving(.north)])
        XCTAssertNil(board.grid[.zero.moving(.north).moving(.east).moving(.northeast)])
    }
}
