//
//  PointExtensionTests.swift
//  MineSweeperTests
//
//  Created by Tyler Thompson on 6/1/21.
//

import Foundation
import XCTest

@testable import MineSweeper

final class PointExtensionTests: XCTestCase {
    func testPointDirectionModification() throws {
        XCTAssertEqual(NSPoint.zero.moving(.northwest), NSPoint(x: -1, y: 1))
        XCTAssertEqual(NSPoint.zero.moving(.north), NSPoint(x: 0, y: 1))
        XCTAssertEqual(NSPoint.zero.moving(.northeast), NSPoint(x: 1, y: 1))
        XCTAssertEqual(NSPoint.zero.moving(.west), NSPoint(x: -1, y: 0))
        XCTAssertEqual(NSPoint.zero.moving(.east), NSPoint(x: 1, y: 0))
        XCTAssertEqual(NSPoint.zero.moving(.southwest), NSPoint(x: -1, y: -1))
        XCTAssertEqual(NSPoint.zero.moving(.south), NSPoint(x: 0, y: -1))
        XCTAssertEqual(NSPoint.zero.moving(.southeast), NSPoint(x: 1, y: -1))
    }
}
