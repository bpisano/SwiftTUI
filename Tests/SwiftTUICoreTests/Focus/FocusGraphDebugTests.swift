//
//  FocusGraphDebugTests.swift
//  SwiftTUI
//
//  Temporary debugging tests for the focus attribute graph.
//  Print the graph to verify shape after each phase.
//

import AttributeGraph
import Foundation
import Geometry
import Testing

@testable import SwiftTUI
@testable import SwiftTUICore

@Test @MainActor
func debugFocusGraph_singleProbe() {
    @Attribute var screenPosition: Point = .zero
    @Attribute var screenSize: Size = .init(width: 100, height: 100)
    @Attribute var viewPhase: ViewPhase = .active
    @Attribute var environment: EnvironmentValues = .init()
    let inputs = ViewInputs(
        position: $screenPosition,
        size: $screenSize,
        phase: $viewPhase,
        environment: $environment,
        storage: .init()
    )

    @Attribute var view = RootLayout { DebugFocusableProbe(id: "a") }

    $screenPosition.label = "Screen Origin"
    $screenSize.label = "Screen Size"
    $viewPhase.label = "View Phase"
    $environment.label = "Environment Values"
    $view.label = "RootLayout(Single Probe)"

    let outputs = type(of: view).makeView($view, inputs: inputs)
    _ = outputs.displayList.wrappedValue
    _ = outputs.focusList?.wrappedValue
    CallbackQueue.shared.executeAll()

    print("=== Single Probe Graph ===")
    print(Graph.current.digraph)
}

@Test @MainActor
func debugFocusGraph_hstackOfVstacks() {
    @Attribute var screenPosition: Point = .zero
    @Attribute var screenSize: Size = .init(width: 100, height: 100)
    @Attribute var viewPhase: ViewPhase = .active
    @Attribute var environment: EnvironmentValues = .init()
    let inputs = ViewInputs(
        position: $screenPosition,
        size: $screenSize,
        phase: $viewPhase,
        environment: $environment,
        storage: .init()
    )

    @Attribute var view = RootLayout {
        HStack {
            VStack {
                DebugFocusableProbe(id: "l1")
                DebugFocusableProbe(id: "l2")
            }
            VStack {
                DebugFocusableProbe(id: "r1")
                DebugFocusableProbe(id: "r2")
            }
        }
    }

    $screenPosition.label = "Screen Origin"
    $screenSize.label = "Screen Size"
    $viewPhase.label = "View Phase"
    $environment.label = "Environment Values"
    $view.label = "RootLayout(HStack of VStacks)"

    let outputs = type(of: view).makeView($view, inputs: inputs)
    _ = outputs.displayList.wrappedValue
    _ = outputs.focusList?.wrappedValue
    CallbackQueue.shared.executeAll()

    print("=== HStack-of-VStacks Graph ===")
    print(Graph.current.digraph)

    let focusList = outputs.focusList?.wrappedValue ?? .empty
    print("=== FocusList items ===")
    dump(focusList)
}

struct DebugFocusableProbe: View, PrimitiveView {
    let id: String

    static func makeView(
        _ view: Attribute<Self>,
        inputs: ViewInputs
    ) -> ViewOutputs {
        let layoutComputer = Attribute("Probe(\(view.wrappedValue.id)) LayoutComputer") {
            LayoutComputer { _ in
                Size(width: 1, height: 1)
            } viewGeometries: { _ in
                []
            }
        }
        let displayList = Attribute("Probe(\(view.wrappedValue.id)) DisplayList") {
            DisplayList([])
        }
        let position = inputs.position
        let size = inputs.size
        let focusList = Attribute("Probe(\(view.wrappedValue.id)) FocusList") {
            let id = FocusNodeID(view.wrappedValue.id)
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
        .unaryViewListOutputs("Probe(\(view.wrappedValue.id))", implicitId: inputs.implicitId) { inputs in
            makeView(view, inputs: inputs)
        }
    }
}
