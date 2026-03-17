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

struct TerminalRenderer {
    private let configuration: RenderingConfiguration

    init(configuration: RenderingConfiguration) {
        self.configuration = configuration
    }

    func renderFrame(
        displayList: DisplayList,
        in size: Size
    ) -> String {
        var buffer: TerminalBuffer = .init(
            configuration: configuration,
            size: size
        )
        fill(buffer: &buffer, with: displayList)
        return buffer.makeStringFrame()
    }

    private func fill(
        buffer: inout TerminalBuffer,
        with displayList: DisplayList
    ) {
        for item in displayList.items {
            switch item {
            case let .childList(wrappedDisplayList):
                fill(
                    buffer: &buffer,
                    with: wrappedDisplayList
                )
            case let .command(command):
                fillCell(
                    buffer: &buffer,
                    with: command
                )
            }
        }
    }

    private func fillCell(
        buffer: inout TerminalBuffer,
        with command: DisplayList.Command
    ) {
        switch command.action {
        case let .putLine(line):
            buffer.putLine(line, at: command.frame.origin)
        }
    }
}


