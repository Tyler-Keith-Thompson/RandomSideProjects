//
//  CellViewTests.swift
//  MineSweeperTests
//
//  Created by Tyler Thompson on 6/1/21.
//

import Foundation
import XCTest
import ViewInspector

@testable import MineSweeper

extension CellView: Inspectable { }

final class CellViewTests: XCTestCase {
    func testCellViewSelected() throws {
        let cell = Cell(coordinate: .init(x: 0, y: 0), board: Board(width: 0, height: 0), isSelected: true)
        let cellView = try CellView(cell: cell).inspect()
        XCTAssertEqual(try cellView.zStack().fixedFrame().width, 35)
        XCTAssertEqual(try cellView.zStack().fixedFrame().height, 35)
        XCTAssertEqual(try cellView.find(ViewType.Text.self).string(), "\(cell.numberOfSurroundingMines)")
    }
    
    func testCellViewUnselected() throws {
        let cell = Cell(coordinate: .init(x: 0, y: 0), board: Board(width: 0, height: 0), isSelected: false)
        let cellView = try CellView(cell: cell).inspect()
        XCTAssertEqual(try cellView.zStack().fixedFrame().width, 35)
        XCTAssertEqual(try cellView.zStack().fixedFrame().height, 35)
        XCTAssertThrowsError(try cellView.find(ViewType.Text.self).string())
    }
}
