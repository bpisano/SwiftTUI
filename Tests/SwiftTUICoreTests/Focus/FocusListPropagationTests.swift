//
//  FocusListPropagationTests.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 21/05/2026.
//

import AttributeGraph
import Foundation
import Geometry
import Testing

@testable import SwiftTUI
@testable import SwiftTUICore

@Suite("FocusList propagation")
@MainActor
struct FocusListPropagationTests {
    @Test
    func `Plain view chain has nil focusList`() {
        let outputs = makeRootOutputs {
            Text("hello")
        }
        #expect(outputs.focusList?.wrappedValue == .empty || outputs.focusList?.wrappedValue.items.isEmpty == true)
    }

    @Test
    func `Single focusable primitive surfaces a node`() {
        let outputs = makeRootOutputs {
            FocusableProbe(id: "a")
        }
        let list = outputs.focusList?.wrappedValue ?? .empty
        let ids = flatten(list)
        #expect(ids == [FocusNodeID("a")])
    }

    @Test
    func `VStack aggregates children focus lists in order`() {
        let outputs = makeRootOutputs {
            VStack {
                FocusableProbe(id: "a")
                FocusableProbe(id: "b")
                FocusableProbe(id: "c")
            }
        }
        let list = outputs.focusList?.wrappedValue ?? .empty
        let ids = flatten(list)
        #expect(ids == [FocusNodeID("a"), FocusNodeID("b"), FocusNodeID("c")])
    }

    @Test
    func `HStack of VStacks preserves DFS order`() {
        let outputs = makeRootOutputs {
            HStack {
                VStack {
                    FocusableProbe(id: "l1")
                    FocusableProbe(id: "l2")
                }
                VStack {
                    FocusableProbe(id: "r1")
                    FocusableProbe(id: "r2")
                }
            }
        }
        let list = outputs.focusList?.wrappedValue ?? .empty
        let ids = flatten(list)
        #expect(ids == [
            FocusNodeID("l1"),
            FocusNodeID("l2"),
            FocusNodeID("r1"),
            FocusNodeID("r2")
        ])
    }

    private func flatten(_ list: FocusList) -> [FocusNodeID] {
        var result: [FocusNodeID] = []
        for item in list.items {
            switch item {
            case .node(let n):
                result.append(n.id)
            case .list(let sublist):
                result.append(contentsOf: flatten(sublist))
            case .group(let g):
                result.append(contentsOf: flatten(g.children))
            }
        }
        return result
    }

    private func makeRootOutputs<V: View>(@ViewBuilder _ content: () -> V) -> ViewOutputs {
        let built: V = content()

        @Attribute var screenOrigin: Point = .zero
        @Attribute var screenSize: Size = .init(width: 20, height: 20)
        @Attribute var viewPhase: ViewPhase = .active
        @Attribute var environment: EnvironmentValues = .init()
        @Attribute var view = RootLayout { built }

        let inputs: ViewInputs = .init(
            position: $screenOrigin,
            size: $screenSize,
            phase: $viewPhase,
            environment: $environment,
            storage: .init()
        )
        let outputs = type(of: view).makeView($view, inputs: inputs)
        _ = outputs.displayList.wrappedValue
        return outputs
    }
}

private struct FocusableProbe: View, PrimitiveView {
    let id: String

    static func makeView(
        _ view: Attribute<Self>,
        inputs: ViewInputs
    ) -> ViewOutputs {
        let layoutComputer = Attribute("FocusableProbe LayoutComputer") {
            LayoutComputer { proposal in
                Size(width: 1, height: 1)
            } viewGeometries: { rect in
                []
            }
        }

        let displayList = Attribute("FocusableProbe DisplayList") {
            DisplayList([])
        }

        let position = inputs.position
        let size = inputs.size
        let focusList = Attribute("FocusableProbe FocusList") {
            let id: FocusNodeID = FocusNodeID(view.wrappedValue.id)
            let frame = Rect(origin: position.wrappedValue, size: size.wrappedValue)
            return FocusList(.node(FocusableNode(id: id, frame: frame)))
        }

        return .init(
            layoutComputer: layoutComputer,
            displayList: displayList,
            focusList: focusList
        )
    }

    static func makeViewList(
        _ view: Attribute<Self>,
        inputs: ViewListInputs
    ) -> ViewListOutputs {
        .unaryViewListOutputs("FocusableProbe", implicitId: inputs.implicitId) { inputs in
            makeView(view, inputs: inputs)
        }
    }
}
