//
//  AnyButtonStyle.swift
//  SwiftTUICore
//
//  Created by Benjamin Pisano on 21/05/2026.
//

import Foundation

/// Type-erased wrapper around a concrete `ButtonStyle`. Lets the environment
/// store a single style without exposing its associated `Body` type.
public struct AnyButtonStyle: Sendable {
    let makeBody: @MainActor @Sendable (ButtonStyleConfiguration) -> AnyView

    @MainActor
    public init<S: ButtonStyle>(_ style: S) {
        self.makeBody = { configuration in
            AnyView(style.makeBody(configuration: configuration))
        }
    }
}
