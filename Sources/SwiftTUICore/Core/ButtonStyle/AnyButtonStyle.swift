//
//  AnyButtonStyle.swift
//  SwiftTUICore
//
//  Created by Benjamin Pisano on 21/05/2026.
//

import Foundation
import AttributeGraph

/// Type-erased wrapper around a concrete `ButtonStyle`. Lets the environment
/// store a single style without exposing its associated `Body` type.
public struct AnyButtonStyle: Sendable {
    let makeBody: @MainActor @Sendable (ButtonStyleConfiguration) -> AnyView
    let wireDynamicProperties: @MainActor @Sendable (Attribute<EnvironmentValues>) -> Void

    @MainActor
    public init<S: ButtonStyle>(_ style: S) {
        self.makeBody = { configuration in
            AnyView(style.makeBody(configuration: configuration))
        }
        self.wireDynamicProperties = { environment in
            let mirror = Mirror(reflecting: style)
            for child in mirror.children {
                if let envProperty = child.value as? EnvironmentProperty {
                    envProperty.update(environment: environment)
                }
            }
        }
    }
}
