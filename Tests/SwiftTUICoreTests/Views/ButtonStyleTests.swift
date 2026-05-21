//
//  ButtonStyleTests.swift
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

@Suite("ButtonStyle")
@MainActor
struct ButtonStyleTests {
    @Test
    func `DefaultButtonStyle renders label with blank caret slots when unfocused`() async {
        await expectView(in: Size(width: 4, height: 1)) {
            Button("OK") {}
        } toRender: {
            " OK "
        }
    }

    @Test
    func `Custom buttonStyle is used`() async {
        await expectView(in: Size(width: 4, height: 1)) {
            Button("OK") {}
                .buttonStyle(BracketsButtonStyle())
        } toRender: {
            "[OK]"
        }
    }

    @Test
    func `Custom style applies to nested Buttons via env`() async {
        await expectView(in: Size(width: 4, height: 2)) {
            VStack {
                Button("OK") {}
                Button("NO") {}
            }
            .buttonStyle(BracketsButtonStyle())
        } toRender: {
            """
            [OK]
            [NO]
            """
        }
    }

    @Test
    func `Style reads isFocused from env`() async {
        let manager: FocusManager = .init()
        var env: EnvironmentValues = .init()
        env.focusManager = manager

        @Attribute var screenOrigin: Point = .zero
        @Attribute var screenSize: Size = .init(width: 6, height: 1)
        @Attribute var viewPhase: ViewPhase = .active
        @Attribute var environment: EnvironmentValues = env
        @Attribute var view = RootLayout {
            Button("X") {}
                .buttonStyle(FocusMarkerButtonStyle())
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

        let list = outputs.focusList?.wrappedValue ?? .empty
        let firstID = flattenNodes(list).first?.id
        #expect(firstID != nil)

        manager.rebuild(from: list)
        manager.setFocus(firstID)
        _ = outputs.focusList?.wrappedValue
        CallbackQueue.shared.executeAll()

        let texts = collectTextLines(outputs.displayList.wrappedValue)
        #expect(texts.contains("F:"))
        #expect(!texts.contains("U:"))
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
}

private struct BracketsButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            Text("[")
            configuration.label
            Text("]")
        }
    }
}

private struct FocusMarkerButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        FocusMarkerBody(label: configuration.label)
    }
}

private struct FocusMarkerBody: View {
    let label: ButtonStyleConfiguration.Label
    @Environment(\.isFocused) private var isFocused

    var body: some View {
        HStack {
            Text(isFocused ? "F:" : "U:")
            label
        }
    }
}
