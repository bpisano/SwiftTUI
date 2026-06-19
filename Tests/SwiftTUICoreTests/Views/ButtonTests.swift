//
//  ButtonTests.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 21/05/2026.
//

import AttributeGraph
import Foundation
import Geometry
import Terminal
import Testing

@testable import SwiftTUI
@testable import SwiftTUICore

@Suite("Button")
@MainActor
struct ButtonTests {
    @Test
    func `Button renders its title surrounded by blank caret slots when unfocused`() async {
        await expectView(in: Size(width: 4, height: 1)) {
            Button("OK") {}
        } toRender: {
            " OK "
        }
    }

    @Test
    func `Button contributes a focusable node`() {
        let outputs = makeOutputs(env: .init()) {
            Button("OK") {}
        }
        let nodes = flattenNodes(outputs.focusList?.wrappedValue ?? .empty)
        #expect(nodes.count == 1)
    }

    @Test
    func `Focused Button shows caret markers around its label`() {
        let manager: FocusManager = .init()
        var env: EnvironmentValues = .init()
        env.focusManager = manager

        let outputs = makeOutputs(env: env) {
            Button("OK") {}
        }
        let list = outputs.focusList?.wrappedValue ?? .empty
        let nodes = flattenNodes(list)
        #expect(nodes.count == 1)

        // Initially unfocused → no caret markers
        let textsBefore = collectTextLines(outputs.displayList.wrappedValue)
        #expect(textsBefore.contains(">") == false)
        #expect(textsBefore.contains("<") == false)

        // Focus the button
        manager.rebuild(from: list)
        manager.setFocus(nodes[0].id)
        // Reading focusList triggers FocusedViewModifier sync → enqueues binding write
        _ = outputs.focusList?.wrappedValue
        CallbackQueue.shared.executeAll()
        let textsAfter = collectTextLines(outputs.displayList.wrappedValue)
        #expect(textsAfter.contains(">"))
        #expect(textsAfter.contains("<"))
    }

    @Test
    func `Focused button runs its action on Return`() {
        let manager: FocusManager = .init()
        var env: EnvironmentValues = .init()
        env.focusManager = manager
        var fired: Int = 0

        let outputs = makeOutputs(env: env) {
            Button("OK") { fired += 1 }
        }
        let list = outputs.focusList?.wrappedValue ?? .empty
        manager.rebuild(from: list)
        let nodes = flattenNodes(list)
        #expect(nodes.count == 1)

        manager.setFocus(nodes[0].id)
        manager.dispatchKeyToFocused(.keyDown(.enter))
        #expect(fired == 1)
    }

    @Test
    func `Unfocused button does not run its action`() {
        let manager: FocusManager = .init()
        var env: EnvironmentValues = .init()
        env.focusManager = manager
        var fired: Int = 0

        let outputs = makeOutputs(env: env) {
            VStack {
                Button("OK") { fired += 1 }
                Text("other").focusable()
            }
        }
        let list = outputs.focusList?.wrappedValue ?? .empty
        manager.rebuild(from: list)
        let nodes = flattenNodes(list)
        #expect(nodes.count == 2)

        manager.setFocus(nodes[1].id) // focus the other node, not the button
        manager.dispatchKeyToFocused(.keyDown(.enter))
        #expect(fired == 0)
    }

    @Test
    func `Only Return triggers the button`() {
        let manager: FocusManager = .init()
        var env: EnvironmentValues = .init()
        env.focusManager = manager
        var fired: Int = 0

        let outputs = makeOutputs(env: env) {
            Button("OK") { fired += 1 }
        }
        let list = outputs.focusList?.wrappedValue ?? .empty
        manager.rebuild(from: list)
        manager.setFocus(flattenNodes(list)[0].id)

        manager.dispatchKeyToFocused(.keyDown(.space))
        manager.dispatchKeyToFocused(.keyDown(.character("a")))
        #expect(fired == 0)

        manager.dispatchKeyToFocused(.keyDown(.enter))
        #expect(fired == 1)
    }

    @Test
    func `Disabled button is not focusable`() {
        let outputs = makeOutputs(env: .init()) {
            Button("OK") {}
                .disabled(true)
        }
        let nodes = flattenNodes(outputs.focusList?.wrappedValue ?? .empty)
        #expect(nodes.isEmpty)
    }

    /// Regression: activation reads the live focus at keystroke time, so it
    /// keeps working across repeated Return presses without the view's `body`
    /// (or focus list) being re-evaluated in between — the exact condition that
    /// left the old `@State`-mirror guard stale.
    @Test
    func `Button keeps activating on repeated Return without re-rendering`() {
        let manager: FocusManager = .init()
        var env: EnvironmentValues = .init()
        env.focusManager = manager
        var fired: Int = 0

        let outputs = makeOutputs(env: env) {
            Button("OK") { fired += 1 }
        }
        // Build the focus map once; never touch displayList/focusList again.
        let list = outputs.focusList?.wrappedValue ?? .empty
        manager.rebuild(from: list)
        manager.setFocus(flattenNodes(list)[0].id)

        manager.dispatchKeyToFocused(.keyDown(.enter))
        manager.dispatchKeyToFocused(.keyDown(.enter))
        manager.dispatchKeyToFocused(.keyDown(.enter))
        #expect(fired == 3)
    }

    // MARK: - helpers

    private func collectTextLines(_ displayList: DisplayList) -> [String] {
        var result: [String] = []
        for item in displayList.items {
            switch item {
            case .command(let cmd):
                if case .putLine(let line) = cmd.action { result.append(line) }
            case .childList(let sub):
                result.append(contentsOf: collectTextLines(sub))
            }
        }
        return result
    }

    private func flattenNodes(_ list: FocusList) -> [FocusableNode] {
        var result: [FocusableNode] = []
        for item in list.items {
            switch item {
            case .node(let n):
                result.append(n)
            case .list(let sublist):
                result.append(contentsOf: flattenNodes(sublist))
            case .group(let g):
                result.append(contentsOf: flattenNodes(g.children))
            }
        }
        return result
    }

    private func makeOutputs<V: View>(
        env: EnvironmentValues,
        @ViewBuilder _ content: () -> V
    ) -> ViewOutputs {
        let built: V = content()

        @Attribute var screenOrigin: Point = .zero
        @Attribute var screenSize: Size = .init(width: 10, height: 3)
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

