//
//  DisplayList.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 10/03/2026.
//

import Foundation
import Geometry
import AttributeGraph

public struct DisplayList {
    public let items: [Item]

    init(_ items: [Item]) {
        self.items = items
    }

    init(commands: [Command]) {
        self.items = commands.map { .command($0) }
    }
}

extension DisplayList {
    public enum Item {
        case command(Command)
        case childList(DisplayList)
    }

    public enum CommandAction {
        case putLine(_ line: String)
    }

    public struct Command {
        public let action: CommandAction
        public let frame: Rect

        init(
            _ action: CommandAction,
            in frame: Rect
        ) {
            self.action = action
            self.frame = frame
        }
    }
}

extension DisplayList: AttributeValueRepresentable {
    public var attributeValueDescription: String {
        if items.isEmpty {
            return "Empty"
        }

        let parts: [String] = items.map { item in
            switch item {
            case .command(let command):
                return "\(command) in \(command.frame)"
            case .childList(let list):
                return "childList(\(list.items.count) items)"
            }
        }

        return parts.joined(separator: "\n")
    }
}
