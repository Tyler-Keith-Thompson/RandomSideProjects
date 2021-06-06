//
//  CellView.swift
//  MineSweeper
//
//  Created by Tyler Thompson on 5/31/21.
//

import SwiftUI

struct CellView: View {
    @State var cell: Cell
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.white.opacity(cell.isSelected ? 0.5 : 0.7))
            if (cell.isSelected) {
                Text("\(cell.numberOfSurroundingMines)").font(.title)
            }
        }
        .overlay(Rectangle().stroke(Color.secondary.opacity(0.5), lineWidth: 4))
        .frame(width: 35, height: 35)
    }
}

#if DEBUG
struct CellView_Previews: PreviewProvider {
    static var previews: some View {
        CellView(cell: Cell(coordinate: .init(x: 0, y: 0), board: Board(width: 2, height: 2), isSelected: false))
    }
}
#endif
