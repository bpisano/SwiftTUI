//
//  OnDisappearTests.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 21/03/2026.
//

import Foundation
import Geometry
import Testing

@testable import AttributeGraph
@testable import SwiftTUICore

@Suite(".onDisappear")
struct OnDisappearTests {
    @Test
    func `onDisappear is called when the view disappears`() async throws {
        @Attribute var screenPosition: Point = .zero
        @Attribute var screenSize: Size = .init(width: 10, height: 10)
        @Attribute var viewPhase: ViewPhase = .active
        let inputs = ViewInputs(
            position: $screenPosition,
            size: $screenSize,
            phase: $viewPhase,
            storage: .init()
        )

        var onDisappearCallCount: Int = 0
        @Attribute var view = Text("Hello")
            .onDisappear {
                onDisappearCallCount += 1
            }

        let outputs: ViewOutputs = type(of: view).makeView(
            $view,
            inputs: inputs
        )
        _ = outputs.displayList.wrappedValue
        CallbackQueue.shared.executeAll()

        viewPhase = .inactive

        _ = outputs.displayList.wrappedValue
        CallbackQueue.shared.executeAll()

        #expect(onDisappearCallCount == 1)
    }

    @Test
    func `onDisappear should only be called once`() async throws {
        @Attribute var screenPosition: Point = .zero
        @Attribute var screenSize: Size = .init(width: 10, height: 10)
        @Attribute var viewPhase: ViewPhase = .active
        let inputs = ViewInputs(
            position: $screenPosition,
            size: $screenSize,
            phase: $viewPhase,
            storage: .init()
        )

        var onDisappearCallCount: Int = 0
        @Attribute var view = Text("Hello")
            .onDisappear {
                onDisappearCallCount += 1
            }

        let outputs: ViewOutputs = type(of: view).makeView(
            $view,
            inputs: inputs
        )
        _ = outputs.displayList.wrappedValue
        CallbackQueue.shared.executeAll()

        viewPhase = .inactive

        _ = outputs.displayList.wrappedValue
        CallbackQueue.shared.executeAll()
        _ = outputs.displayList.wrappedValue
        CallbackQueue.shared.executeAll()

        #expect(onDisappearCallCount == 1)
    }

    @Test
    func `onDisappear should not be called when view appears`() async throws {
        @Attribute var screenPosition: Point = .zero
        @Attribute var screenSize: Size = .init(width: 10, height: 10)
        @Attribute var viewPhase: ViewPhase = .active
        let inputs = ViewInputs(
            position: $screenPosition,
            size: $screenSize,
            phase: $viewPhase,
            storage: .init()
        )

        var onDisappearCallCount: Int = 0
        @Attribute var view = Text("Hello")
            .onDisappear {
                onDisappearCallCount += 1
            }

        let outputs: ViewOutputs = type(of: view).makeView(
            $view,
            inputs: inputs
        )
        _ = outputs.displayList.wrappedValue
        CallbackQueue.shared.executeAll()

        #expect(onDisappearCallCount == 0)
    }

    @Test
    func `should work inside view lists`() async throws {
        @Attribute var screenPosition: Point = .zero
        @Attribute var screenSize: Size = .init(width: 10, height: 10)
        @Attribute var viewPhase: ViewPhase = .active
        let inputs = ViewInputs(
            position: $screenPosition,
            size: $screenSize,
            phase: $viewPhase,
            storage: .init()
        )

        var onDisappearCallCount: Int = 0
        @Attribute var view = VStack {
            Text("Hello")
                .onDisappear {
                    onDisappearCallCount += 1
                }
        }

        let outputs: ViewOutputs = type(of: view).makeView(
            $view,
            inputs: inputs
        )
        _ = outputs.displayList.wrappedValue
        CallbackQueue.shared.executeAll()

        viewPhase = .inactive

        _ = outputs.displayList.wrappedValue
        CallbackQueue.shared.executeAll()

        #expect(onDisappearCallCount == 1)
    }
}
