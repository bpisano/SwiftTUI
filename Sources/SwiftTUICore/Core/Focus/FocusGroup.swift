//
//  FocusGroup.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 21/05/2026.
//

import Foundation

public struct FocusGroup: Sendable, Hashable {
    public let id: FocusNodeID
    public let children: FocusList

    public init(id: FocusNodeID, children: FocusList) {
        self.id = id
        self.children = children
    }
}
