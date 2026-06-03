//
//  FocusNodeID.swift
//  SwiftTUICore
//
//  Created by Benjamin Pisano on 21/05/2026.
//

import Foundation

@_documentation(visibility: internal)
public struct FocusNodeID: Hashable, @unchecked Sendable, CustomStringConvertible {
    private let raw: AnyHashable

    public init<H: Hashable & Sendable>(_ value: H) {
        self.raw = AnyHashable(value)
    }

    public var description: String {
        "FocusNodeID(\(raw))"
    }
}
