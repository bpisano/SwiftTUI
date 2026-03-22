//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 29/01/2026.
//

import SwiftTUI

@main
struct MyApp: App {
    var body: some View {
        MyView()
    }
}

struct MyView: View {
    var body: some View {
        ChessBoardLayout(cellSize: 4) {
            ForEach(0..<8, id: \.self) { row in
                ForEach(0..<8, id: \.self) { column in
                    ZStack {
                        let isBlack = (row + column) % 2 != 0
                        Color(isBlack ? .brightBlack : .white)
                        Text("\(row),\(column)")
                    }
                }
            }
        }
    }
}

struct ChessBoardLayout: Layout {
    let cellSize: GeometryUnit

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: [Subview]
    ) -> Size {
        let width: GeometryUnit = cellSize * 8
        let height: GeometryUnit = cellSize / 2 * 8
        return .init(width: width, height: height)
    }

    func placeSubviews(
        in bounds: Rect,
        subviews: [Subview]
    ) {
        for (index, subview) in subviews.enumerated() {
            let row = index / 8
            let column = index % 8
            let x = bounds.origin.x + GeometryUnit(column) * cellSize
            let y = bounds.origin.y + GeometryUnit(row) * cellSize / 2
            let rect: Rect = .init(
                x: x,
                y: y,
                width: cellSize,
                height: cellSize / 2
            )
            subview.place(in: rect)
        }
    }
}
