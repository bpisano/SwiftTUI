//
//  FocusManagerEnvironment.swift
//  SwiftTUICore
//
//  Created by Benjamin Pisano on 21/05/2026.
//

import Foundation

struct FocusManagerEnvironmentKey: EnvironmentKey {
    static let defaultValue: FocusManager? = nil
}

extension EnvironmentValues {
    public var focusManager: FocusManager? {
        get { self[FocusManagerEnvironmentKey.self] }
        set { self[FocusManagerEnvironmentKey.self] = newValue }
    }
}
