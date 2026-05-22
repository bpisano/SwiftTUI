//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 27/01/2026.
//

import Foundation
import AttributeGraph
import Geometry
import Terminal
import SwiftTUICore

public actor TerminalRenderer {
    private let configuration: RenderingConfiguration

    public init(configuration: RenderingConfiguration) {
        self.configuration = configuration
    }

    public func renderFrame(
        displayList: DisplayList,
        in size: Size
    ) -> Frame {
        var buffer: TerminalBuffer = .init(
            configuration: configuration,
            size: size
        )
        var cursorAnchor: Point? = nil
        fill(buffer: &buffer, cursorAnchor: &cursorAnchor, with: displayList)
        return Frame(content: buffer.makeStringFrame(), cursorAnchor: cursorAnchor)
    }

    private func fill(
        buffer: inout TerminalBuffer,
        cursorAnchor: inout Point?,
        with displayList: DisplayList
    ) {
        var stack: [DisplayList.Item] = displayList.items.reversed()
        while let item = stack.popLast() {
            switch item {
            case let .childList(child):
                stack.append(contentsOf: child.items.reversed())
            case let .command(command):
                fillCell(buffer: &buffer, cursorAnchor: &cursorAnchor, with: command)
            }
        }
    }

    private func fillCell(
        buffer: inout TerminalBuffer,
        cursorAnchor: inout Point?,
        with command: DisplayList.Command
    ) {
        switch command.action {
        case let .putLine(line):
            buffer.putLine(line, at: command.frame.origin)
        case let .backgroundColor(color):
            buffer.setBackgroundColor(color, in: command.frame)
        case let .foregroundColor(color):
            buffer.setForegroundColor(color, in: command.frame)
        case .cursorAnchor:
            cursorAnchor = command.frame.origin
        }
    }
}

extension TerminalRenderer {
    public struct Frame: Sendable {
        public let content: String
        public let cursorAnchor: Point?
    }
}
