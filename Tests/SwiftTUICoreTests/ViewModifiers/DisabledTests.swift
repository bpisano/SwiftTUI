//
//  DisabledTests.swift
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

@Suite(".disabled")
@MainActor
struct DisabledTests {
    @Test
    func `Default isEnabled is true`() {
        let env = EnvironmentValues()
        #expect(env.isEnabled == true)
    }

    @Test
    func `disabled() writes false into child env`() {
        let probe: EnvProbe = .init()

        @Attribute var screenOrigin: Point = .zero
        @Attribute var screenSize: Size = .init(width: 5, height: 1)
        @Attribute var viewPhase: ViewPhase = .active
        @Attribute var environment: EnvironmentValues = .init()
        @Attribute var view = EnvProbeView(probe: probe).disabled()

        let inputs: ViewInputs = .init(
            position: $screenOrigin,
            size: $screenSize,
            phase: $viewPhase,
            environment: $environment,
            storage: .init()
        )
        let outputs = type(of: view).makeView($view, inputs: inputs)
        _ = outputs.displayList.wrappedValue

        #expect(probe.isEnabled == false)
    }

    @Test
    func `Nested disabled(false) does NOT re-enable (sticky)`() {
        let probe: EnvProbe = .init()

        @Attribute var screenOrigin: Point = .zero
        @Attribute var screenSize: Size = .init(width: 5, height: 1)
        @Attribute var viewPhase: ViewPhase = .active
        @Attribute var environment: EnvironmentValues = .init()
        @Attribute var view = EnvProbeView(probe: probe)
            .disabled(false)
            .disabled(true)

        let inputs: ViewInputs = .init(
            position: $screenOrigin,
            size: $screenSize,
            phase: $viewPhase,
            environment: $environment,
            storage: .init()
        )
        let outputs = type(of: view).makeView($view, inputs: inputs)
        _ = outputs.displayList.wrappedValue

        #expect(probe.isEnabled == false)
    }

    @Test
    func `Disabled Button does not contribute focusable`() {
        @Attribute var screenOrigin: Point = .zero
        @Attribute var screenSize: Size = .init(width: 10, height: 1)
        @Attribute var viewPhase: ViewPhase = .active
        @Attribute var environment: EnvironmentValues = .init()
        @Attribute var view = RootLayout {
            Button("Hi") {}.disabled()
        }

        let inputs: ViewInputs = .init(
            position: $screenOrigin,
            size: $screenSize,
            phase: $viewPhase,
            environment: $environment,
            storage: .init()
        )
        let outputs = type(of: view).makeView($view, inputs: inputs)
        _ = outputs.displayList.wrappedValue

        let nodes = flattenNodes(outputs.focusList?.wrappedValue ?? .empty)
        #expect(nodes.isEmpty)
    }

    @Test
    func `Enabled Button still contributes focusable`() {
        @Attribute var screenOrigin: Point = .zero
        @Attribute var screenSize: Size = .init(width: 10, height: 1)
        @Attribute var viewPhase: ViewPhase = .active
        @Attribute var environment: EnvironmentValues = .init()
        @Attribute var view = RootLayout {
            Button("Hi") {}
        }

        let inputs: ViewInputs = .init(
            position: $screenOrigin,
            size: $screenSize,
            phase: $viewPhase,
            environment: $environment,
            storage: .init()
        )
        let outputs = type(of: view).makeView($view, inputs: inputs)
        _ = outputs.displayList.wrappedValue

        let nodes = flattenNodes(outputs.focusList?.wrappedValue ?? .empty)
        #expect(nodes.count == 1)
    }

    @Test
    func `Toggling disabled removes the focusable dynamically`() {
        @Attribute var screenOrigin: Point = .zero
        @Attribute var screenSize: Size = .init(width: 10, height: 1)
        @Attribute var viewPhase: ViewPhase = .active
        @Attribute var environment: EnvironmentValues = .init()
        @Attribute var view = RootLayout {
            Button("Hi") {}.disabled(false)
        }

        let inputs: ViewInputs = .init(
            position: $screenOrigin,
            size: $screenSize,
            phase: $viewPhase,
            environment: $environment,
            storage: .init()
        )
        let outputs = type(of: view).makeView($view, inputs: inputs)
        _ = outputs.displayList.wrappedValue
        let enabledNodes = flattenNodes(outputs.focusList?.wrappedValue ?? .empty)
        #expect(enabledNodes.count == 1)

        // A unary modifier (`.disabled`) wraps a view whose body switches branches
        // on `isEnabled`. Toggling it must re-materialize the wrapped content so the
        // button stops contributing a focusable node.
        view = RootLayout {
            Button("Hi") {}.disabled(true)
        }
        _ = outputs.displayList.wrappedValue
        let disabledNodes = flattenNodes(outputs.focusList?.wrappedValue ?? .empty)
        #expect(disabledNodes.isEmpty)
    }

    private func flattenNodes(_ list: FocusList) -> [FocusableNode] {
        var result: [FocusableNode] = []
        for item in list.items {
            switch item {
            case .node(let n): result.append(n)
            case .list(let s): result.append(contentsOf: flattenNodes(s))
            case .group(let g): result.append(contentsOf: flattenNodes(g.children))
            }
        }
        return result
    }
}

@MainActor
private final class EnvProbe {
    var isEnabled: Bool = true
}

private struct EnvProbeView: View {
    @Environment(\.isEnabled) var isEnabled
    let probe: EnvProbe

    var body: some View {
        let _ = { probe.isEnabled = isEnabled }()
        Text("p")
    }
}
