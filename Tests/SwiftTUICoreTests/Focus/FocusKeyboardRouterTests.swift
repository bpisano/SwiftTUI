//
//  FocusKeyboardRouterTests.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 21/05/2026.
//

import Foundation
import Geometry
import Testing

@testable import SwiftTUI
@testable import SwiftTUICore
@testable import Terminal

@Suite("FocusKeyboardRouter")
@MainActor
struct FocusKeyboardRouterTests {
    @Test
    func `Tab moves to next`() {
        let manager = makeManager(["a", "b", "c"])
        let router: FocusKeyboardRouter = .init(manager: manager)
        router.handle(.keyDown(.tab))
        #expect(manager.currentFocus == FocusNodeID("a"))
        router.handle(.keyDown(.tab))
        #expect(manager.currentFocus == FocusNodeID("b"))
    }

    @Test
    func `Shift+Tab moves to previous`() {
        let manager = makeManager(["a", "b"])
        manager.setFocus(FocusNodeID("b"))
        let router: FocusKeyboardRouter = .init(manager: manager)
        router.handle(.keyDown(.tab, modifiers: .shift))
        #expect(manager.currentFocus == FocusNodeID("a"))
    }

    @Test
    func `Arrow keys map to spatial moves`() {
        let manager = makeGridManager()
        manager.setFocus(FocusNodeID("a"))
        let router: FocusKeyboardRouter = .init(manager: manager)

        router.handle(.keyDown(.arrowRight))
        #expect(manager.currentFocus == FocusNodeID("b"))

        router.handle(.keyDown(.arrowDown))
        #expect(manager.currentFocus == FocusNodeID("d"))

        router.handle(.keyDown(.arrowLeft))
        #expect(manager.currentFocus == FocusNodeID("c"))

        router.handle(.keyDown(.arrowUp))
        #expect(manager.currentFocus == FocusNodeID("a"))
    }

    @Test
    func `Non-focus keys are ignored`() {
        let manager = makeManager(["a", "b"])
        let router: FocusKeyboardRouter = .init(manager: manager)
        router.handle(.keyDown(.character("x")))
        #expect(manager.currentFocus == nil)
        router.handle(.keyDown(.enter))
        #expect(manager.currentFocus == nil)
    }

    @Test
    func `Key repeat keeps navigating`() {
        let manager = makeManager(["a", "b", "c"])
        let router: FocusKeyboardRouter = .init(manager: manager)
        router.handle(.keyDown(.arrowDown))
        #expect(manager.currentFocus == FocusNodeID("a"))
        router.handle(.keyRepeat(.arrowDown))
        #expect(manager.currentFocus == FocusNodeID("b"))
        router.handle(.keyRepeat(.arrowDown))
        #expect(manager.currentFocus == FocusNodeID("c"))
    }

    @Test
    func `Up events are ignored`() {
        let manager = makeManager(["a", "b"])
        let router: FocusKeyboardRouter = .init(manager: manager)
        router.handle(.keyUp(.tab))
        #expect(manager.currentFocus == nil)
    }

    @Test
    func `start subscribes to keyboard stream and routes events`() async {
        let keyboard = TestKeyboard()
        let manager = makeManager(["a", "b"])
        let router: FocusKeyboardRouter = .init(manager: manager, keyboard: keyboard.value)
        router.start()
        defer { router.stop(); keyboard.finish() }

        keyboard.send(.keyDown(.tab))
        await waitUntil { manager.currentFocus == FocusNodeID("a") }
        #expect(manager.currentFocus == FocusNodeID("a"))
    }

    // MARK: - helpers

    private func makeManager(_ ids: [String]) -> FocusManager {
        let manager: FocusManager = .init()
        let items: [FocusList.Item] = ids.enumerated().map { idx, id in
            .node(FocusableNode(
                id: FocusNodeID(id),
                frame: Rect(x: 0, y: Double(idx), width: 1, height: 1)
            ))
        }
        manager.rebuild(from: FocusList(items: items))
        return manager
    }

    private func makeGridManager() -> FocusManager {
        // 2x2 grid:
        //   a b
        //   c d
        let manager: FocusManager = .init()
        manager.rebuild(from: FocusList(
            .node(FocusableNode(id: FocusNodeID("a"), frame: Rect(x: 0, y: 0, width: 1, height: 1))),
            .node(FocusableNode(id: FocusNodeID("b"), frame: Rect(x: 2, y: 0, width: 1, height: 1))),
            .node(FocusableNode(id: FocusNodeID("c"), frame: Rect(x: 0, y: 2, width: 1, height: 1))),
            .node(FocusableNode(id: FocusNodeID("d"), frame: Rect(x: 2, y: 2, width: 1, height: 1)))
        ))
        return manager
    }
}

private func waitUntil(_ condition: @MainActor () -> Bool) async {
    for _ in 0..<20 {
        if condition() { return }
        await Task.yield()
    }
}

private final class TestKeyboard {
    let value: Keyboard

    private let continuation: AsyncStream<Keyboard.Event>.Continuation

    init() {
        var continuation: AsyncStream<Keyboard.Event>.Continuation?
        let stream = AsyncStream<Keyboard.Event> { streamContinuation in
            continuation = streamContinuation
        }

        self.continuation = continuation!
        self.value = Keyboard { stream }
    }

    func send(_ event: Keyboard.Event) {
        continuation.yield(event)
    }

    func finish() {
        continuation.finish()
    }
}
