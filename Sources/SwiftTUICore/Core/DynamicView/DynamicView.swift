//
//  DynamicView.swift
//  SwiftTUICore
//
//  Created by Benjamin Pisano on 06/06/2026.
//

import Foundation
import AttributeGraph

/// A primitive view that resolves to one of several child variants and can transition
/// between them at runtime — conditionals (`if`/`else`, `switch`), optionals (`if let`)
/// and type-erased containers (`AnyView`).
///
/// Conformers expose a ``dynamicBranchId`` identifying the active variant. While that id
/// is stable the child is updated in place (its attributes react to value changes). When
/// it changes, the framework tears the previous variant's subgraph down completely and
/// builds the new one from scratch — mirroring OpenSwiftUI's `DynamicView` `Container`
/// (`matches` → reuse, otherwise `eraseInfo` + `makeInfo`).
///
/// Because every nesting level is its own reactive container, a branch flip deep inside a
/// nested conditional rebuilds only that level and propagates outward through live
/// attributes — there is no materialize-once cache that can go stale.
@MainActor
protocol DynamicView: PrimitiveView {
    var dynamicBranchId: AnyHashable { get }

    static func makeDynamicChildView(
        _ view: Attribute<Self>,
        inputs: ViewInputs
    ) -> ViewOutputs

    static func makeDynamicChildViewList(
        _ view: Attribute<Self>,
        inputs: ViewListInputs
    ) -> ViewListOutputs
}

extension DynamicView {
    public static func makeView(
        _ view: Attribute<Self>,
        inputs: ViewInputs
    ) -> ViewOutputs {
        let rule: DynamicViewOutputsRule<Self> = .init(view: view, inputs: inputs)
        let viewOutputs: Attribute<ViewOutputs> = .init("\(Self.self) ViewOutputs", rule: rule)

        let layoutComputer: Attribute<LayoutComputer> = .init("\(Self.self) LayoutComputer") {
            viewOutputs.wrappedValue.layoutComputer.wrappedValue
        }

        let displayList: Attribute<DisplayList> = .init("\(Self.self) DisplayList") {
            viewOutputs.wrappedValue.displayList.wrappedValue
        }

        let focusList: Attribute<FocusList> = .init("\(Self.self) FocusList") {
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
        let rule: DynamicViewListRule<Self> = .init(view: view, inputs: inputs)
        let viewList: Attribute<any ViewList> = .init("\(Self.self) ViewList", rule: rule)
        return .init(views: .dynamicList(viewList), nextImplicitId: inputs.implicitId + 1)
    }
}
