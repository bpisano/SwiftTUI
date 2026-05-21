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
    func `Button renders its title text`() async {
        await expectView(in: Size(width: 4, height: 1)) {
            Button("OK") {}
        } toRender: {
            "OK.."
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
    func `Focused Button issues backgroundColor gray command`() {
        let manager: FocusManager = .init()
        var env: EnvironmentValues = .init()
        env.focusManager = manager

        let outputs = makeOutputs(env: env) {
            Button("OK") {}
        }
        let list = outputs.focusList?.wrappedValue ?? .empty
        let nodes = flattenNodes(list)
        #expect(nodes.count == 1)

        // Initially unfocused → no bg command
        let dlBefore = outputs.displayList.wrappedValue
        #expect(findBackgroundColor(dlBefore) == nil)

        // Focus the button
        manager.rebuild(from: list)
        manager.setFocus(nodes[0].id)
        // Reading focusList triggers FocusedViewModifier sync → enqueues binding write
        _ = outputs.focusList?.wrappedValue
        CallbackQueue.shared.executeAll()
        let dlAfter = outputs.displayList.wrappedValue
        #expect(findBackgroundColor(dlAfter) == .gray)
    }

    // MARK: - helpers

    private func findBackgroundColor(_ displayList: DisplayList) -> ANSIColor? {
        for item in displayList.items {
            switch item {
            case .command(let cmd):
                if case .backgroundColor(let color) = cmd.action { return color }
            case .childList(let sub):
                if let c = findBackgroundColor(sub) { return c }
            }
        }
        return nil
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

