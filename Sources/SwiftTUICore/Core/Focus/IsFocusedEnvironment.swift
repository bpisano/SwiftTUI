//
//  IsFocusedEnvironment.swift
//  SwiftTUICore
//
//  Created by Benjamin Pisano on 21/05/2026.
//

import Foundation

struct IsFocusedEnvironmentKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    public var isFocused: Bool {
        get { self[IsFocusedEnvironmentKey.self] }
        set { self[IsFocusedEnvironmentKey.self] = newValue }
    }
}
