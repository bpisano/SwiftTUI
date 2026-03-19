//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 27/01/2026.
//

import Foundation
import Geometry
import Terminal

struct TerminalBuffer: Sendable {
    typealias Frame = [[TerminalBufferCell]]

    let configuration: RenderingConfiguration
    let size: Size

    private var frame: Frame

    init(
        configuration: RenderingConfiguration,
        size: Size
    ) {
        self.configuration = configuration
        self.size = size
        self.frame = Array(
            repeating: Array(
                repeating: TerminalBufferCell(configuration.emptyChar),
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

    mutating func setBackgroundColor(_ color: ANSIColor, at origin: Point) {
        guard origin.y >= 0 && origin.y < size.height else { return }
        let rowIndex: Int = Int(origin.y)
        let columnIndex: Int = Int(origin.x)
        frame[rowIndex][columnIndex].setBackgroundColor(color)
    }

    func makeStringFrame() -> String {
        frame.map { row in
            row.map { cell in
                cell.stringValue(includeColors: configuration.renderColor)
            }.joined()
        }.joined(separator: configuration.lineJoinSeparator)
    }
}
