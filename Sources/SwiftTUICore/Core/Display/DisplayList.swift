//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 20/11/2025.
//

import Foundation
import Geometry

public struct DisplayList {
    public let items: [Item]

    init(_ items: [Item]) {
        self.items = items
    }
}

extension DisplayList {
    public struct Item {
        public enum Content {
            case empty
            case command(DrawCommand)
            case childList(DisplayList)
        }

        public let content: Content
        public let frame: Rect
    }
}

extension DisplayList: CustomStringConvertible {
    public var description: String {
        if items.isEmpty {
            return "Empty"
        }

        let parts: [String] = items.map { item in
            switch item.content {
            case .empty:
                return "empty in \(item.frame)"
            case .command(let drawCommand):
                return "\(drawCommand) in \(item.frame)"
            case .childList(let list):
                return "childList(\(list.items.count) items) in \(item.frame)"
            }
        }

        return parts.joined(separator: "\n")
    }
}
