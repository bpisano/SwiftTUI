//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 20/11/2025.
//

import Foundation
import Geometry

struct DisplayList {
    let items: [Item]

    init(_ items: [Item]) {
        self.items = items
    }
}

extension DisplayList {
    struct Item {
        enum Content {
            case empty
            case command(DrawCommand)
            case childList(DisplayList)
        }

        let content: Content
        let frame: Rect
    }
}

extension DisplayList: CustomStringConvertible {
    var description: String {
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

        return parts.joined(separator: "<br />")
    }
}
