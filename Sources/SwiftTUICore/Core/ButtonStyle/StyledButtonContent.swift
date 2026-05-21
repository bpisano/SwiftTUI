//
//  StyledButtonContent.swift
//  SwiftTUICore
//
//  Created by Benjamin Pisano on 21/05/2026.
//

import Foundation
import AttributeGraph

/// Internal helper: invokes the env-resolved `ButtonStyle.makeBody` with
/// `@Environment` properties on the user's style struct correctly wired to
/// the live attribute graph. Needed because `ButtonStyle` is not a `View` —
/// the framework's normal mirror walk on `Attribute<View>` does not reach it.
struct StyledButtonContent: View, PrimitiveView {
    let label: AnyView
    let isPressed: Bool

    static func makeView(
        _ view: Attribute<StyledButtonContent>,
        inputs: ViewInputs
    ) -> ViewOutputs {
        let environment = inputs.environment

        let resolvedBody = Attribute("StyledButtonContent Body") {
            let env = environment.wrappedValue
            let style = env.buttonStyle
            style.wireDynamicProperties(environment)
            let configuration = ButtonStyleConfiguration(
                label: view.wrappedValue.label,
                isPressed: view.wrappedValue.isPressed
            )
            return style.makeBody(configuration)
        }

        return AnyView.makeView(resolvedBody, inputs: inputs)
    }

    static func makeViewList(
        _ view: Attribute<StyledButtonContent>,
        inputs: ViewListInputs
    ) -> ViewListOutputs {
        .unaryViewListOutputs("StyledButtonContent ViewList", implicitId: inputs.implicitId) { inputs in
            Self.makeView(view, inputs: inputs)
        }
    }
}
