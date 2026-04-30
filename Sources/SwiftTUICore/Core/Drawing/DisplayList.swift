//
//  DisplayList.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 10/03/2026.
//

import Foundation
import Terminal
import Geometry
import AttributeGraph

public struct DisplayList: Codable, Sendable {
    public let items: [Item]

    public init(items: [Item]) {
        self.items = items
    }

    init(_ items: [Item]) {
        self.items = items
    }

    public init(commands: [Command]) {
        self.items = commands.map { .command($0) }
    }
}

extension DisplayList {
    public enum Item: Codable, Sendable {
        case command(Command)
        case childList(DisplayList)
    }

    public enum CommandAction: Codable, Sendable {
        case putLine(_ line: String)
        case backgroundColor(_ color: ANSIColor)
        case foregroundColor(_ color: ANSIColor)
    }

    public struct Command: Codable, Sendable {
        public let action: CommandAction
        public let frame: Rect

        public init(
            action: CommandAction,
            frame: Rect
        ) {
            self.action = action
            self.frame = frame
        }

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
