//
//  FocusModifiersTests.swift
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

nonisolated enum MockFocus: Hashable, Sendable {
    case none
    case save
    case cancel
}

@Suite(".focusable / .focused / .focusGroup")
@MainActor
struct FocusModifiersTests {
    @Test
    func `focusable adds a single node to focus list`() {
        let outputs = makeRootOutputs {
            Text("a").focusable()
        }
        let nodes = flattenNodes(outputs.focusList?.wrappedValue ?? .empty)
        #expect(nodes.count == 1)
        #expect(nodes[0].isEnabled == true)
        #expect(nodes[0].frame.width > 0)
    }

    @Test
    func `focusable(false) adds disabled node`() {
        let outputs = makeRootOutputs {
            Text("a").focusable(false)
        }
        let nodes = flattenNodes(outputs.focusList?.wrappedValue ?? .empty)
        #expect(nodes.count == 1)
        #expect(nodes[0].isEnabled == false)
    }

    @Test
    func `multiple focusables in VStack appear in DFS order`() {
        let outputs = makeRootOutputs {
            VStack {
                Text("a").focusable()
                Text("b").focusable()
                Text("c").focusable()
            }
        }
        let nodes = flattenNodes(outputs.focusList?.wrappedValue ?? .empty)
        #expect(nodes.count == 3)
    }

    @Test
    func `focusGroup wraps inner focusables in a group`() {
        let outputs = makeRootOutputs {
            VStack {
                Text("l").focusable()
                VStack {
                    Text("r1").focusable()
                    Text("r2").focusable()
                }
                .focusGroup()
            }
        }
        let list = outputs.focusList?.wrappedValue ?? .empty
        let groups = collectGroups(list)
        #expect(groups.count == 1)
        let group = groups[0]
        let innerNodes = flattenNodes(group.children)
        #expect(innerNodes.count == 2)

        let allNodes = flattenNodes(list)
        #expect(allNodes.count == 3)
    }

    @Test
    func `focusGroup with no focusable children produces empty list`() {
        let outputs = makeRootOutputs {
            Text("solo").focusGroup()
        }
        let list = outputs.focusList?.wrappedValue ?? .empty
        #expect(list.items.isEmpty)
    }

    @Test
    func `focused binding equals target -> manager focuses node`() async {
        let probe = BindingProbe<MockFocus>(initial: .save)
        let manager: FocusManager = .init()
        var env: EnvironmentValues = .init()
        env.focusManager = manager

        let outputs = makeOutputsWith(environment: env) {
            Text("a")
                .focused(probe.binding, equals: .save)
        }

        manager.rebuild(from: outputs.focusList?.wrappedValue ?? .empty)
        _ = outputs.focusList?.wrappedValue
        CallbackQueue.shared.executeAll()

        let nodes = flattenNodes(outputs.focusList?.wrappedValue ?? .empty)
        #expect(nodes.count == 1)
        #expect(manager.currentFocus == nodes[0].id)
    }

    @Test
    func `Manager focusing node writes target into binding`() async {
        let probe = BindingProbe<MockFocus>(initial: .none)
        let manager: FocusManager = .init()
        var env: EnvironmentValues = .init()
        env.focusManager = manager

        let outputs = makeOutputsWith(environment: env) {
            Text("a")
                .focused(probe.binding, equals: .save)
        }

        let list = outputs.focusList?.wrappedValue ?? .empty
        manager.rebuild(from: list)

        let nodes = flattenNodes(list)
        #expect(nodes.count == 1)

        manager.setFocus(nodes[0].id)
        _ = outputs.focusList?.wrappedValue
        CallbackQueue.shared.executeAll()

        #expect(probe.value == .save)
    }

    @Test
    func `Two focused() siblings sharing a binding settle without ping-pong`() async {
        let probe = BindingProbe<MockFocus>(initial: .none)
        let manager: FocusManager = .init()
        var env: EnvironmentValues = .init()
        env.focusManager = manager

        let outputs = makeOutputsWith(environment: env) {
            VStack {
                Text("save").focused(probe.binding, equals: .save)
                Text("cancel").focused(probe.binding, equals: .cancel)
            }
        }

        let list = outputs.focusList?.wrappedValue ?? .empty
        manager.rebuild(from: list)
        let nodes = flattenNodes(list)
        #expect(nodes.count == 2)

        // Tab onto "save" — manager picks first, sync mirrors to binding.
        manager.setFocus(nodes[0].id)
        for _ in 0..<5 {
            _ = outputs.focusList?.wrappedValue
            CallbackQueue.shared.executeAll()
        }
        #expect(probe.value == .save)
        #expect(manager.currentFocus == nodes[0].id)

        // Tab onto "cancel" — manager moves, the previous sibling must NOT claim back.
        manager.setFocus(nodes[1].id)
        for _ in 0..<5 {
            _ = outputs.focusList?.wrappedValue
            CallbackQueue.shared.executeAll()
        }
        #expect(probe.value == .cancel)
        #expect(manager.currentFocus == nodes[1].id)
    }

    @Test
    func `Bool binding: focus moves -> binding mirrors true and false`() async {
        let probe = BindingProbe<Bool>(initial: false)
        let manager: FocusManager = .init()
        var env: EnvironmentValues = .init()
        env.focusManager = manager

        let outputs = makeOutputsWith(environment: env) {
            VStack {
                Text("a").focused(probe.binding)
                Text("b").focusable()
            }
        }

        let list = outputs.focusList?.wrappedValue ?? .empty
        manager.rebuild(from: list)
        let nodes = flattenNodes(list)
        #expect(nodes.count == 2)

        manager.setFocus(nodes[0].id)
        _ = outputs.focusList?.wrappedValue
        CallbackQueue.shared.executeAll()
        #expect(probe.value == true)

        manager.setFocus(nodes[1].id)
        _ = outputs.focusList?.wrappedValue
        CallbackQueue.shared.executeAll()
        #expect(probe.value == false)
    }

    // MARK: - helpers

    @MainActor
    private final class BindingProbe<V: Sendable> {
        private let attribute: Attribute<V>

        init(initial: V) {
            self.attribute = Attribute(wrappedValue: initial)
        }

        var value: V { attribute.wrappedValue }

        var binding: Binding<V> {
            Binding(
                get: { self.attribute.wrappedValue },
                set: { self.attribute.wrappedValue = $0 }
            )
        }
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

    private func collectGroups(_ list: FocusList) -> [FocusGroup] {
        var result: [FocusGroup] = []
        for item in list.items {
            switch item {
            case .node:
                break
            case .list(let sublist):
                result.append(contentsOf: collectGroups(sublist))
            case .group(let g):
                result.append(g)
                result.append(contentsOf: collectGroups(g.children))
            }
        }
        return result
    }

    private func makeRootOutputs<V: View>(@ViewBuilder _ content: () -> V) -> ViewOutputs {
        makeOutputsWith(environment: .init(), content: content)
    }

    private func makeOutputsWith<V: View>(
        environment env: EnvironmentValues,
        @ViewBuilder content: () -> V
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
        let outputs = type(of: view).makeView($view, inputs: inputs)
        _ = outputs.displayList.wrappedValue
        return outputs
    }
}
