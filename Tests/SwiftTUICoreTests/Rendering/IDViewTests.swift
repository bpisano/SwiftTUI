//
//  IDViewTests.swift
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

@Suite("View.id")
@MainActor
struct IDViewTests {
    @MainActor
    final class Probe {
        var appearances: Int = 0
        var bump: (() -> Void)?
    }

    private struct AppearingCounter: View {
        let probe: Probe

        var body: some View {
            Text("hi")
                .onAppear { probe.appearances += 1 }
        }
    }

    private struct Counter: View {
        @State var value: Int = 0
        let probe: Probe

        var body: some View {
            let _ = { probe.bump = { value += 1 } }()
            return Text("value=\(value)")
        }
    }

    /// Changing the identity discards the view's state: a fresh `@State`, back to its initial
    /// value, replaces the mutated one. Read through the rendered output.
    @Test
    func `Changing id resets state`() {
        let probe: Probe = .init()
        let graph: Graph = .init()
        Graph.withCurrent(graph) {
            @Attribute var screenOrigin: Point = .zero
            @Attribute var screenSize: Size = .init(width: 12, height: 2)
            @Attribute var viewPhase: ViewPhase = .active
            @Attribute var environment: EnvironmentValues = .init()
            @Attribute var view = RootLayout { Counter(probe: probe).id(0) }

            let inputs: ViewInputs = .init(
                position: $screenOrigin,
                size: $screenSize,
                phase: $viewPhase,
                environment: $environment,
                storage: .init()
            )
            let outputs = type(of: view).makeView($view, inputs: inputs)
            let display: @MainActor () -> String = { textContent(outputs.displayList.wrappedValue) }

            #expect(display().contains("value=0"))

            // State persists across a plain re-render (same id).
            probe.bump?()
            #expect(display().contains("value=1"))

            // Changing the id rebuilds the view, resetting its state.
            view = RootLayout { Counter(probe: probe).id(1) }
            let after: String = display()
            #expect(after.contains("value=0"))
            #expect(!after.contains("value=1"))
        }
    }

    private func textContent(_ list: DisplayList) -> String {
        var result: String = ""
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

    /// Changing the identity makes `onAppear` fire again for the new view, confirming the
    /// view is rebuilt rather than updated in place.
    @Test
    func `Changing id re-fires onAppear`() {
        let probe: Probe = .init()
        let graph: Graph = .init()
        Graph.withCurrent(graph) {
            @Attribute var screenOrigin: Point = .zero
            @Attribute var screenSize: Size = .init(width: 12, height: 2)
            @Attribute var viewPhase: ViewPhase = .active
            @Attribute var environment: EnvironmentValues = .init()
            @Attribute var view = RootLayout { AppearingCounter(probe: probe).id(0) }

            let inputs: ViewInputs = .init(
                position: $screenOrigin,
                size: $screenSize,
                phase: $viewPhase,
                environment: $environment,
                storage: .init()
            )
            let outputs = type(of: view).makeView($view, inputs: inputs)

            let render: @MainActor () -> Void = {
                _ = outputs.displayList.wrappedValue
                CallbackQueue.shared.executeAll()
            }

            render()
            let afterFirst: Int = probe.appearances
            #expect(afterFirst >= 1)

            view = RootLayout { AppearingCounter(probe: probe).id(1) }
            render()
            #expect(probe.appearances > afterFirst)
        }
    }
}
