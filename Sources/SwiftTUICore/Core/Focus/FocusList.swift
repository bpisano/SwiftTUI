//
//  FocusList.swift
//  SwiftTUICore
//
//  Created by Benjamin Pisano on 21/05/2026.
//

import Foundation
import Geometry

public struct FocusList: Sendable, Hashable {
    public let items: [Item]

    public static let empty: FocusList = .init(items: [])

    public init(items: [Item]) {
        self.items = items
    }

    public init(_ items: Item...) {
        self.items = items
    }

    public func appending(_ other: FocusList) -> FocusList {
        FocusList(items: items + other.items)
    }

    public static func concat(_ lists: [FocusList]) -> FocusList {
        FocusList(items: lists.flatMap { $0.items })
    }
}

extension FocusList {
    public indirect enum Item: Sendable, Hashable {
        case node(FocusableNode)
        case list(FocusList)
        case group(FocusGroup)
    }
}
