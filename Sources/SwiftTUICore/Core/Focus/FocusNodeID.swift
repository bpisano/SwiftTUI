//
//  FocusNodeID.swift
//  SwiftTUICore
//
//  Created by Benjamin Pisano on 2026-05-21.
//

import Foundation

public struct FocusNodeID: Hashable, @unchecked Sendable, CustomStringConvertible {
    private let raw: AnyHashable

    public init<H: Hashable & Sendable>(_ value: H) {
        self.raw = AnyHashable(value)
    }

    public var description: String {
        "FocusNodeID(\(raw))"
    }
}
