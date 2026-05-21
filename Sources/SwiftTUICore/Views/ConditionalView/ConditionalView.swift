//
//  File.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 31/03/2026.
//

import Foundation
import AttributeGraph

public struct ConditionalView<TrueContent: View, FalseContent: View>: View, PrimitiveView {
    enum Storage {
        case trueContent(TrueContent)
        case falseContent(FalseContent)
    }

    let storage: Storage

    init(_ storage: Storage) {
        self.storage = storage
    }
}

extension ConditionalView {
    public static func makeView(
        _ view: Attribute<Self>,
        inputs: ViewInputs
    ) -> ViewOutputs {
        let viewOutputsRule: ConditionalViewOutputsRule<TrueContent, FalseContent> = .init(
            view: view,
            inputs: inputs
        )
        let viewOutputs: Attribute<ViewOutputs> = Attribute(
            "ConditionalView ViewOutputs",
            rule: viewOutputsRule
        )

        let layoutComputer = Attribute("ConditionalView LayoutComputer") {
            viewOutputs.wrappedValue.layoutComputer.wrappedValue
        }

        let displayList = Attribute("ConditionalView DisplayList") {
            viewOutputs.wrappedValue.displayList.wrappedValue
        }

        let focusList = Attribute("ConditionalView FocusList") {
            viewOutputs.wrappedValue.focusList?.wrappedValue ?? .empty
        }

        return .init(
            layoutComputer: layoutComputer,
            displayList: displayList,
            focusList: focusList
        )
    }

    public static func makeViewList(
        _ view: Attribute<Self>,
        inputs: ViewListInputs
    ) -> ViewListOutputs {
        let viewListRule: ConditionalViewListRule<TrueContent, FalseContent> = .init(
            view: view,
            inputs: inputs
        )
        let viewList = Attribute(
            "ConditionalView ViewList",
            rule: viewListRule
        )
        return ViewListOutputs(views: .dynamicList(viewList), nextImplicitId: inputs.implicitId + 1)
    }
}
