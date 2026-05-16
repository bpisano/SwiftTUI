//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 27/01/2026.
//

import Foundation
import Geometry
import Terminal

nonisolated struct TerminalBuffer: Sendable {
    let configuration: RenderingConfiguration
    let size: Size

    private var cells: [TerminalBufferCell]

    init(
        configuration: RenderingConfiguration,
        size: Size
    ) {
        self.configuration = configuration
        self.size = size
        self.cells = Array(
            repeating: TerminalBufferCell(configuration.emptyChar),
            count: Int(size.width) * Int(size.height)
        )
    }

    mutating func putLine(_ line: String, at origin: Point) {
        guard origin.y >= 0 && origin.y < size.height else { return }
        let row: Int = Int(origin.y)
        let width: Int = Int(size.width)
        for (i, character) in line.enumerated() {
            let col: Int = Int(origin.x) + i
            guard col >= 0 && col < width else { continue }
            cells[row * width + col].setCharacter(character)
        }
    }

    mutating func setBackgroundColor(_ color: ANSIColor, in rect: Rect) {
        let startRow: Int = max(0, Int(rect.origin.y))
        let endRow: Int = min(Int(size.height), Int(rect.origin.y + rect.size.height))
        let startCol: Int = max(0, Int(rect.origin.x))
        let endCol: Int = min(Int(size.width), Int(rect.origin.x + rect.size.width))

        guard endRow >= startRow else { return }
        guard endCol >= startCol else { return }

        for row in startRow..<endRow {
            let base: Int = row * Int(size.width)
            for col in startCol..<endCol {
                cells[base + col].setBackgroundColor(color)
            }
        }
    }

    mutating func setForegroundColor(_ color: ANSIColor, in rect: Rect) {
        let startRow: Int = max(0, Int(rect.origin.y))
        let endRow: Int = min(Int(size.height), Int(rect.origin.y + rect.size.height))
        let startCol: Int = max(0, Int(rect.origin.x))
        let endCol: Int = min(Int(size.width), Int(rect.origin.x + rect.size.width))

        guard endRow >= startRow else { return }
        guard endCol >= startCol else { return }

        for row in startRow..<endRow {
            let base: Int = row * Int(size.width)
            for col in startCol..<endCol {
                cells[base + col].setForegroundColor(color)
            }
        }
    }

    func makeStringFrame() -> String {
        let width: Int = Int(size.width)
        let height: Int = Int(size.height)
        let includeColors: Bool = configuration.renderColor

        var result: String = ""
        result.reserveCapacity(width * height + height * configuration.lineJoinSeparator.count)

        if includeColors {
            var activeForeground: ANSIColor = .default
            var activeBackground: ANSIColor = .default

            for row in 0..<height {
                let base = row * width
                for col in 0..<width {
                    let cell = cells[base + col]
                    if cell.foregroundColor != activeForeground {
                        result += cell.foregroundColor.foregroundCode
                        activeForeground = cell.foregroundColor
                    }
                    if cell.backgroundColor != activeBackground {
                        result += cell.backgroundColor.backgroundCode
                        activeBackground = cell.backgroundColor
                    }
                    result.append(cell.character)
                }
                if row < height - 1 {
                    result += configuration.lineJoinSeparator
                }
            }

            if activeForeground != .default { result += ANSIColor.default.foregroundCode }
            if activeBackground != .default { result += ANSIColor.default.backgroundCode }
        } else {
            for row in 0..<height {
                let base = row * width
                for col in 0..<width {
                    result.append(cells[base + col].character)
                }
                if row < height - 1 {
                    result += configuration.lineJoinSeparator
                }
            }
        }

        return result
    }
}
