//
//  IsEnabledEnvironment.swift
//  SwiftTUICore
//
//  Created by Benjamin Pisano on 21/05/2026.
//

import Foundation

struct IsEnabledEnvironmentKey: EnvironmentKey {
    static let defaultValue: Bool = true
}

extension EnvironmentValues {
    public var isEnabled: Bool {
        get { self[IsEnabledEnvironmentKey.self] }
        set { self[IsEnabledEnvironmentKey.self] = newValue }
    }
}
