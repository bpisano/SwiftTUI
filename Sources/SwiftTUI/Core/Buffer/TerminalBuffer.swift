//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 27/01/2026.
//

import Foundation
import Geometry

struct TerminalBuffer: Sendable {
    let size: Size
    
    private var cells: [[TerminalCell]]

    init(size: Size) {
        self.size = size
        self.cells = Array(
            repeating: Array(
                repeating: TerminalCell(),
                count: Int(size.width)
            ),
            count: Int(size.height)
        )
    }

    mutating func putLine(_ line: String, at origin: Point) {
        guard origin.y >= 0 && origin.y < size.height else { return }
        let rowIndex: Int = Int(origin.y)
        for (i, character) in line.enumerated() {
            let columnIndex: Int = Int(origin.x) + i
            guard columnIndex >= 0 && columnIndex < Int(size.width) else { continue }
            cells[rowIndex][columnIndex].setCharacter(character)
        }
    }

    func render() -> [String] {
        cells.map { row in
            row.map { cell in
                cell.render()
            }.joined()
        }
    }
}
