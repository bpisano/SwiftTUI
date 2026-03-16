//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 27/01/2026.
//

import Foundation
import Geometry

struct TerminalBuffer: Sendable {
    typealias Frame = [[TerminalBufferCell]]

    let size: Size

    private var frame: Frame

    init(size: Size) {
        self.size = size
        self.frame = Array(
            repeating: Array(
                repeating: TerminalBufferCell(),
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
            frame[rowIndex][columnIndex].setCharacter(character)
        }
    }

    func makeStringFrame(emptyChar: Character = " ") -> String {
        frame.map { row in
            row.map { cell in
                cell.stringValue(emptyChar: emptyChar)
            }.joined()
        }.joined(separator: "\n")
    }
}
