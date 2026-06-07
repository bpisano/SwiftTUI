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

extension ConditionalView: DynamicView {
    var dynamicBranchId: AnyHashable {
        switch storage {
        case .trueContent: AnyHashable(true)
        case .falseContent: AnyHashable(false)
        }
    }

    static func makeDynamicChildView(
        _ view: Attribute<Self>,
        inputs: ViewInputs
    ) -> ViewOutputs {
        switch view.wrappedValue.storage {
        case .trueContent:
            return TrueContent.makeView(trueChild(of: view), inputs: inputs)
        case .falseContent:
            return FalseContent.makeView(falseChild(of: view), inputs: inputs)
        }
    }

    static func makeDynamicChildViewList(
        _ view: Attribute<Self>,
        inputs: ViewListInputs
    ) -> ViewListOutputs {
        switch view.wrappedValue.storage {
        case .trueContent:
            return TrueContent.makeViewList(trueChild(of: view), inputs: inputs)
        case .falseContent:
            return FalseContent.makeViewList(falseChild(of: view), inputs: inputs)
        }
    }

    private static func trueChild(of view: Attribute<Self>) -> Attribute<TrueContent> {
        .init(
            "Conditional True Child",
            rule: DynamicChildRule(parent: view) { view in
                guard case let .trueContent(content) = view.storage else { return nil }
                return content
            }
        )
    }

    private static func falseChild(of view: Attribute<Self>) -> Attribute<FalseContent> {
        .init(
            "Conditional False Child",
            rule: DynamicChildRule(parent: view) { view in
                guard case let .falseContent(content) = view.storage else { return nil }
                return content
            }
        )
    }
}
