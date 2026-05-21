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

