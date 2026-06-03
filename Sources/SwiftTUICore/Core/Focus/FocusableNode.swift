//
//  FocusableNode.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 21/05/2026.
//

import Foundation
import Geometry

@_documentation(visibility: internal)
public struct FocusableNode: Sendable, Hashable {
    public let id: FocusNodeID
    public let frame: Rect
    public let isEnabled: Bool

    public init(
        id: FocusNodeID,
        frame: Rect,
        isEnabled: Bool = true
    ) {
        self.id = id
        self.frame = frame
        self.isEnabled = isEnabled
    }
}
