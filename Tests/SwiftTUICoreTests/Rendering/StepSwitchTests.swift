//
//  StepSwitchTests.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 06/06/2026.
//

import AttributeGraph
import Foundation
import Geometry
import Testing

@testable import SwiftTUI
@testable import SwiftTUICore

@Suite("Nested conditional switch")
@MainActor
struct StepSwitchTests {
    // MARK: - Contrast: a single conditional (2-case) switches correctly.

    private struct TwoCase: View {
        let which: Int
        var body: some View {
            if which == 0 {
                VStack { Text("AAA"); Button("a") {} }
            } else {
                VStack { Text("BBB"); Button("b") {} }
            }
        }
    }

    @Test
    func `Two-case switch swaps display`() {
        @Attribute var view = RootLayout { TwoCase(which: 0) }
        let outputs = makeOutputs($view)
        _ = outputs.displayList.wrappedValue
        #expect(textContent(outputs.displayList.wrappedValue).contains("AAA"))

        view = RootLayout { TwoCase(which: 1) }
        let s = textContent(outputs.displayList.wrappedValue)
        #expect(s.contains("BBB"))
        #expect(!s.contains("AAA"))
    }

    // MARK: - Bug: a nested conditional (3+ cases) does NOT switch.

    private struct ThreeCase: View {
        let which: Int
        var body: some View {
            switch which {
            case 0:
                VStack { Text("AAA"); Button("a") {} }
            case 1:
                VStack { Text("BBB"); Button("b") {} }
            default:
                VStack { Text("CCC"); Button("c") {} }
            }
        }
    }

    @Test
    func `Nested three-case switch swaps display`() {
        @Attribute var view = RootLayout { ThreeCase(which: 0) }
        let outputs = makeOutputs($view)
        _ = outputs.displayList.wrappedValue
        #expect(textContent(outputs.displayList.wrappedValue).contains("AAA"))

        view = RootLayout { ThreeCase(which: 1) }
        let s1 = textContent(outputs.displayList.wrappedValue)
        #expect(s1.contains("BBB"))
        #expect(!s1.contains("AAA"))

        view = RootLayout { ThreeCase(which: 2) }
        let s2 = textContent(outputs.displayList.wrappedValue)
        #expect(s2.contains("CCC"))
    }

    // MARK: - helpers

    private func makeOutputs<V: View>(_ view: Attribute<V>) -> ViewOutputs {
        @Attribute var screenOrigin: Point = .zero
        @Attribute var screenSize: Size = .init(width: 20, height: 8)
        @Attribute var viewPhase: ViewPhase = .active
        @Attribute var environment: EnvironmentValues = .init()
        let inputs: ViewInputs = .init(
            position: $screenOrigin,
            size: $screenSize,
            phase: $viewPhase,
            environment: $environment,
            storage: .init()
        )
        return V.makeView(view, inputs: inputs)
    }

    private func textContent(_ list: DisplayList) -> String {
        var result = ""
        for item in list.items {
            switch item {
            case .command(let command):
                if case .putLine(let line) = command.action {
                    result += line
                }
            case .childList(let sub):
                result += textContent(sub)
            }
        }
        return result
    }
}
