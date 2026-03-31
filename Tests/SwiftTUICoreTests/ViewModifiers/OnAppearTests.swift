//
//  File.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 21/03/2026.
//

import Foundation
import Geometry
import Testing

@testable import AttributeGraph
@testable import SwiftTUICore

@Suite(".onAppear")
struct OnAppearTests {
    @Test
    func `onAppear is called when the view appears`() async throws {
        @Attribute var screenPosition: Point = .zero
        @Attribute var screenSize: Size = .init(width: 10, height: 10)
        @Attribute var viewPhase: ViewPhase = .active
        let inputs = ViewInputs(
            position: $screenPosition,
            size: $screenSize,
            phase: $viewPhase,
            storage: .init()
        )

        var onAppearCallCount: Int = 0
        @Attribute var view = Text("Hello")
            .onAppear {
                onAppearCallCount += 1
            }

        let outputs: ViewOutputs = type(of: view).makeView(
            $view,
            inputs: inputs
        )
        _ = outputs.displayList.wrappedValue
        CallbackQueue.shared.executeAll()

        #expect(onAppearCallCount == 1)
    }

    @Test
    func `onAppear should only be called once`() async throws {
        @Attribute var screenPosition: Point = .zero
        @Attribute var screenSize: Size = .init(width: 10, height: 10)
        @Attribute var viewPhase: ViewPhase = .active
        let inputs = ViewInputs(
            position: $screenPosition,
            size: $screenSize,
            phase: $viewPhase,
            storage: .init()
        )

        var onAppearCallCount: Int = 0
        @Attribute var view = Text("Hello")
            .onAppear {
                onAppearCallCount += 1
            }

        let outputs: ViewOutputs = type(of: view).makeView(
            $view,
            inputs: inputs
        )
        _ = outputs.displayList.wrappedValue
        CallbackQueue.shared.executeAll()
        _ = outputs.displayList.wrappedValue
        CallbackQueue.shared.executeAll()

        #expect(onAppearCallCount == 1)
    }

    @Test
    func `onAppear not be called when view phase become inactive`() async throws {
        @Attribute var screenPosition: Point = .zero
        @Attribute var screenSize: Size = .init(width: 10, height: 10)
        @Attribute var viewPhase: ViewPhase = .active
        let inputs = ViewInputs(
            position: $screenPosition,
            size: $screenSize,
            phase: $viewPhase,
            storage: .init()
        )

        var onAppearCallCount: Int = 0
        @Attribute var view = Text("Hello")
            .onAppear {
                onAppearCallCount += 1
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

        #expect(onAppearCallCount == 1)
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

        var onAppearCallCount: Int = 0
        @Attribute var view = VStack {
            Text("Hello")
                .onAppear {
                    onAppearCallCount += 1
                }
        }

        let outputs: ViewOutputs = type(of: view).makeView(
            $view,
            inputs: inputs
        )
        _ = outputs.displayList.wrappedValue
        CallbackQueue.shared.executeAll()

        #expect(onAppearCallCount == 1)
    }

    @Test
    func `should be called each time a conditional branch becomes active`() async throws {
        @Attribute var screenPosition: Point = .zero
        @Attribute var screenSize: Size = .init(width: 10, height: 10)
        @Attribute var viewPhase: ViewPhase = .active
        let inputs = ViewInputs(
            position: $screenPosition,
            size: $screenSize,
            phase: $viewPhase,
            storage: .init()
        )

        @Attribute var showHello = false
        var onAppearCallCount: Int = 0
        @Attribute var view = VStack {
            if showHello {
                Text("Hello")
                    .onAppear {
                        onAppearCallCount += 1
                    }
            } else {
                Text("Hidden")
            }
        }

        let outputs: ViewOutputs = type(of: view).makeView(
            $view,
            inputs: inputs
        )

        _ = outputs.displayList.wrappedValue
        CallbackQueue.shared.executeAll()
        #expect(onAppearCallCount == 0)

        showHello = true

        _ = outputs.displayList.wrappedValue
        CallbackQueue.shared.executeAll()
        #expect(onAppearCallCount == 1)

        showHello = false

        _ = outputs.displayList.wrappedValue
        CallbackQueue.shared.executeAll()
        #expect(onAppearCallCount == 1)

        showHello = true

        _ = outputs.displayList.wrappedValue
        CallbackQueue.shared.executeAll()
        #expect(onAppearCallCount == 2)
    }
}
