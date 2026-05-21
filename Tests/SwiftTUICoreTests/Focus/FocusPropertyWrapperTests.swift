//
//  FocusPropertyWrapperTests.swift
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

@Suite("@Focus")
@MainActor
struct FocusPropertyWrapperTests {
    @Test
    func `@Focus pulls manager from environment`() {
        let manager: FocusManager = .init()
        let focus = Focus()
        @Attribute var env: EnvironmentValues = {
            var e = EnvironmentValues()
            e.focusManager = manager
            return e
        }()
        focus.update(environment: $env)

        #expect(manager.currentFocus == nil)
    }

    @Test
    func `focus(.next) advances focus`() {
        let manager: FocusManager = .init()
        manager.rebuild(from: makeList(["a", "b", "c"]))

        let focus = Focus()
        @Attribute var env: EnvironmentValues = {
            var e = EnvironmentValues()
            e.focusManager = manager
            return e
        }()
        focus.update(environment: $env)

        #expect(focus(.next) == true)
        #expect(manager.currentFocus == FocusNodeID("a"))
        #expect(focus(.next) == true)
        #expect(manager.currentFocus == FocusNodeID("b"))
    }

    @Test
    func `focus(.previous) goes backward`() {
        let manager: FocusManager = .init()
        manager.rebuild(from: makeList(["a", "b"]))
        manager.setFocus(FocusNodeID("b"))

        let focus = Focus()
        @Attribute var env: EnvironmentValues = {
            var e = EnvironmentValues()
            e.focusManager = manager
            return e
        }()
        focus.update(environment: $env)

        focus(.previous)
        #expect(manager.currentFocus == FocusNodeID("a"))
    }

    @Test
    func `focus(.down) moves spatially`() {
        let manager: FocusManager = .init()
        manager.rebuild(from: makeList(["a", "b"]))
        manager.setFocus(FocusNodeID("a"))

        let focus = Focus()
        @Attribute var env: EnvironmentValues = {
            var e = EnvironmentValues()
            e.focusManager = manager
            return e
        }()
        focus.update(environment: $env)

        focus(.down)
        #expect(manager.currentFocus == FocusNodeID("b"))
    }

    @Test
    func `focus(.clear) removes focus`() {
        let manager: FocusManager = .init()
        manager.rebuild(from: makeList(["a"]))
        manager.setFocus(FocusNodeID("a"))

        let focus = Focus()
        @Attribute var env: EnvironmentValues = {
            var e = EnvironmentValues()
            e.focusManager = manager
            return e
        }()
        focus.update(environment: $env)

        focus(.clear)
        #expect(manager.currentFocus == nil)
    }

    @Test
    func `Without manager returns false`() {
        let focus = Focus()
        @Attribute var env: EnvironmentValues = .init()
        focus.update(environment: $env)

        #expect(focus(.next) == false)
    }

    @Test
    func `@Focus inside a view receives the injected manager`() {
        let manager: FocusManager = .init()
        manager.rebuild(from: makeList(["x", "y"]))

        var env: EnvironmentValues = .init()
        env.focusManager = manager

        let captured: CapturedFocus = .init()
        let outputs = renderRootOutputs(env: env) {
            FocusControllerView(captured: captured)
        }
        _ = outputs.displayList.wrappedValue
        CallbackQueue.shared.executeAll()

        #expect(captured.focus != nil)
        captured.focus?(.next)
        #expect(manager.currentFocus == FocusNodeID("x"))
    }

    // MARK: - helpers

    private func makeList(_ ids: [String]) -> FocusList {
        let items: [FocusList.Item] = ids.enumerated().map { (idx, id) in
            .node(FocusableNode(
                id: FocusNodeID(id),
                frame: Rect(x: 0, y: Double(idx), width: 1, height: 1)
            ))
        }
        return FocusList(items: items)
    }

    private func renderRootOutputs<V: View>(
        env: EnvironmentValues,
        @ViewBuilder _ content: () -> V
    ) -> ViewOutputs {
        let built: V = content()
        @Attribute var screenOrigin: Point = .zero
        @Attribute var screenSize: Size = .init(width: 20, height: 20)
        @Attribute var viewPhase: ViewPhase = .active
        @Attribute var environment: EnvironmentValues = env
        @Attribute var view = RootLayout { built }

        let inputs: ViewInputs = .init(
            position: $screenOrigin,
            size: $screenSize,
            phase: $viewPhase,
            environment: $environment,
            storage: .init()
        )
        return type(of: view).makeView($view, inputs: inputs)
    }
}

@MainActor
private final class CapturedFocus {
    var focus: Focus?
}

private struct FocusControllerView: View {
    @Focus var focus
    let captured: CapturedFocus

    var body: some View {
        let _ = { captured.focus = focus }()
        Text("controller")
    }
}
