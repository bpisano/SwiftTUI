//
//  KeyboardEventModifierTests.swift
//  SwiftTUI
//
//  Created on 25/04/2026.
//

import Foundation
import Geometry
import Testing

@testable import AttributeGraph
@testable import SwiftTUI
@testable import SwiftTUICore
@testable import Terminal

@Suite("keyboard event modifiers")
@MainActor
struct KeyboardEventModifierTests {
    @Test
    func `onKeyPressed is called for down and repeat events`() async throws {
        let graph = Graph()
        await Graph.withCurrent(graph) {
            let keyboard = TestKeyboard()
            let inputs = makeInputs()
            var receivedEvents: [Keyboard.Event] = []

            @Attribute var view = Text("Hello")
                .modifier(
                    KeyboardEventViewModifier(
                        keyboard: keyboard.value,
                        trigger: .pressed,
                        key: nil,
                        modifiers: nil
                    ) { event in
                        receivedEvents.append(event)
                    }
                )

            let outputs = type(of: view).makeView($view, inputs: inputs)
            _ = outputs.displayList.wrappedValue
            CallbackQueue.shared.executeAll()

            keyboard.send(.keyDown(.character("a")))
            keyboard.send(.keyRepeat(.character("b")))
            keyboard.send(.keyUp(.character("c")))
            await waitUntil { receivedEvents.count == 2 }

            #expect(receivedEvents.map(\.key) == [.character("a"), .character("b")])

            keyboard.finish()
        }
    }

    @Test
    func `onKeyDown ignores repeat and up events`() async throws {
        let graph = Graph()
        await Graph.withCurrent(graph) {
            let keyboard = TestKeyboard()
            let inputs = makeInputs()
            var callCount = 0

            @Attribute var view = Text("Hello")
                .modifier(
                    KeyboardEventViewModifier(
                        keyboard: keyboard.value,
                        trigger: .down,
                        key: nil,
                        modifiers: nil
                    ) { _ in
                        callCount += 1
                    }
                )

            let outputs = type(of: view).makeView($view, inputs: inputs)
            _ = outputs.displayList.wrappedValue
            CallbackQueue.shared.executeAll()

            keyboard.send(.keyRepeat(.character("a")))
            keyboard.send(.keyUp(.character("a")))
            keyboard.send(.keyDown(.character("a")))
            await waitUntil { callCount == 1 }

            #expect(callCount == 1)

            keyboard.finish()
        }
    }

    @Test
    func `onKeyUp is called for release events`() async throws {
        let graph = Graph()
        await Graph.withCurrent(graph) {
            let keyboard = TestKeyboard()
            let inputs = makeInputs()
            var releasedKeys: [Keyboard.Key] = []

            @Attribute var view = Text("Hello")
                .modifier(
                    KeyboardEventViewModifier(
                        keyboard: keyboard.value,
                        trigger: .up,
                        key: nil,
                        modifiers: nil
                    ) { event in
                        releasedKeys.append(event.key)
                    }
                )

            let outputs = type(of: view).makeView($view, inputs: inputs)
            _ = outputs.displayList.wrappedValue
            CallbackQueue.shared.executeAll()

            keyboard.send(.keyDown(.enter))
            keyboard.send(.keyUp(.enter))
            await waitUntil { releasedKeys == [.enter] }

            #expect(releasedKeys == [.enter])

            keyboard.finish()
        }
    }

    @Test
    func `keyboard modifiers filter by key and modifier set`() async throws {
        let graph = Graph()
        await Graph.withCurrent(graph) {
            let keyboard = TestKeyboard()
            let inputs = makeInputs()
            let requiredModifiers: Keyboard.Modifiers = [.shift, .option]
            var callCount = 0

            @Attribute var view = Text("Hello")
                .modifier(
                    KeyboardEventViewModifier(
                        keyboard: keyboard.value,
                        trigger: .pressed,
                        key: .character("a"),
                        modifiers: requiredModifiers
                    ) { _ in
                        callCount += 1
                    }
                )

            let outputs = type(of: view).makeView($view, inputs: inputs)
            _ = outputs.displayList.wrappedValue
            CallbackQueue.shared.executeAll()

            keyboard.send(.keyDown(.character("a"), modifiers: .shift))
            keyboard.send(.keyDown(.character("b"), modifiers: requiredModifiers))
            keyboard.send(.keyDown(.character("a"), modifiers: requiredModifiers))
            await waitUntil { callCount == 1 }

            #expect(callCount == 1)

            keyboard.finish()
        }
    }
}

@MainActor
private func makeInputs() -> ViewInputs {
    @Attribute var screenPosition: Point = .zero
    @Attribute var screenSize: Size = .init(width: 10, height: 10)
    @Attribute var viewPhase: ViewPhase = .active

    return ViewInputs(
        position: $screenPosition,
        size: $screenSize,
        phase: $viewPhase,
        environment: .init(wrappedValue: .init()),
        storage: .init()
    )
}

private func waitUntil(
    _ condition: @MainActor () -> Bool
) async {
    for _ in 0..<20 {
        if condition() {
            return
        }
        await Task.yield()
    }
}

@MainActor
private final class TestKeyboard {
    let value: Keyboard

    private struct Handler {
        let id: UUID
        let action: @MainActor @Sendable (Keyboard.Event) -> Void
    }

    private let continuation: AsyncStream<Keyboard.Event>.Continuation
    private let state: TestKeyboardState

    init() {
        var continuation: AsyncStream<Keyboard.Event>.Continuation?
        let stream = AsyncStream<Keyboard.Event> { streamContinuation in
            continuation = streamContinuation
        }
        self.continuation = continuation!

        let state = TestKeyboardState()
        self.state = state

        self.value = Keyboard(
            events: { stream },
            subscribe: { priority, handler in
                let id = UUID()
                state.add(id: id, priority: priority, handler: handler)
                return InputSubscription {
                    state.remove(id: id)
                }
            }
        )
    }

    func send(_ event: Keyboard.Event) {
        state.dispatch(event)
        continuation.yield(event)
    }

    func finish() {
        continuation.finish()
    }
}

nonisolated private final class TestKeyboardState: @unchecked Sendable {
    private var viewHandlers: [(id: UUID, action: @MainActor @Sendable (Keyboard.Event) -> Void)] = []
    private var systemHandlers: [(id: UUID, action: @MainActor @Sendable (Keyboard.Event) -> Void)] = []
    private let lock = NSLock()

    func add(
        id: UUID,
        priority: Keyboard.SubscriberPriority,
        handler: @escaping @MainActor @Sendable (Keyboard.Event) -> Void
    ) {
        lock.withLock {
            switch priority {
            case .view: viewHandlers.append((id, handler))
            case .system: systemHandlers.append((id, handler))
            }
        }
    }

    func remove(id: UUID) {
        lock.withLock {
            viewHandlers.removeAll { $0.id == id }
            systemHandlers.removeAll { $0.id == id }
        }
    }

    @MainActor
    func dispatch(_ event: Keyboard.Event) {
        let view = lock.withLock { viewHandlers }
        let system = lock.withLock { systemHandlers }
        for h in view { h.action(event) }
        for h in system where !event.isConsumed { h.action(event) }
    }
}
