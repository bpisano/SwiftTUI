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
    private let tileSize: GeometryUnit = 4

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Color(.red)
                .frame(width: 2, height: 2)
            Text("A")
                .padding([.bottom, .trailing], 1)
            Text("B")
//            Color(.white)
//                .frame(width: tileSize * 8, height: tileSize / 2 * 8)
//            BlackTilesLayout(cellSize: tileSize) {
//                ForEach(0..<32, id: \.self) { _ in
//                    Color(.brightBlack)
//                }
//            }
        }
    }
}

struct BlackTilesLayout: Layout {
    let cellSize: GeometryUnit

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: [Subview],
        cache: inout Void
    ) -> Size {
        let width: GeometryUnit = cellSize * 8
        let height: GeometryUnit = cellSize / 2 * 8
        return .init(width: width, height: height)
    }

    func placeSubviews(
        in bounds: Rect,
        subviews: [Subview],
        cache: inout Void
    ) {
        for (index, subview) in subviews.enumerated() {
            let row = index / 4
            let positionInRow = index % 4
            // Even rows have black tiles on odd columns; odd rows on even columns.
            let column = row % 2 == 0 ? positionInRow * 2 + 1 : positionInRow * 2
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
