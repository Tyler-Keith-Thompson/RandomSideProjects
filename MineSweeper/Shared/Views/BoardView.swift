//
//  BoardView.swift
//  MineSweeper
//
//  Created by Tyler Thompson on 6/1/21.
//

import SwiftUI

struct BoardView: View {
    let board: Board
    var body: some View {
        ScrollView {
            VStack {
                ForEach(0..<board.height) { y in
                    HStack {
                        ForEach(0..<board.width) { x in
                            if let cell = board.grid[NSPoint(x: x, y: y)] {
                                CellView(cell: cell)
                            }
                        }
                    }
                }
            }
        }
    }
}

#if DEBUG
struct BoardView_Previews: PreviewProvider {
    static var previews: some View {
        BoardView(board: Board(width: 2, height: 2))
    }
}
#endif
