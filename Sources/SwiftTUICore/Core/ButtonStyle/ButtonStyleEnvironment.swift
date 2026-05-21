//
//  ButtonStyleEnvironment.swift
//  SwiftTUICore
//
//  Created by Benjamin Pisano on 21/05/2026.
//

import Foundation

struct ButtonStyleEnvironmentKey: EnvironmentKey {
    static let defaultValue: AnyButtonStyle = {
        MainActor.assumeIsolated {
            AnyButtonStyle(DefaultButtonStyle())
        }
    }()
}

extension EnvironmentValues {
    public var buttonStyle: AnyButtonStyle {
        get { self[ButtonStyleEnvironmentKey.self] }
        set { self[ButtonStyleEnvironmentKey.self] = newValue }
    }
}

extension View {
    public func buttonStyle<S: ButtonStyle>(_ style: S) -> some View {
        environment(\.buttonStyle, AnyButtonStyle(style))
    }
}
