//
//  FocusKeyDispatchTests.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 19/06/2026.
//

import Foundation
import Geometry
import Testing

@testable import SwiftTUI
@testable import SwiftTUICore
@testable import Terminal

@Suite("Focus-scoped key dispatch")
@MainActor
struct FocusKeyDispatchTests {
    @Test
    func `handler fires only while its node holds focus`() {
        let manager = makeManager(["a", "b"])
        var fired: Int = 0
        _ = manager.registerKeyHandler(node: FocusNodeID("a")) { _ in fired += 1 }

        // Nothing focused yet.
        manager.dispatchKeyToFocused(.keyDown(.enter))
        #expect(fired == 0)

        // Focus elsewhere.
        manager.setFocus(FocusNodeID("b"))
        manager.dispatchKeyToFocused(.keyDown(.enter))
        #expect(fired == 0)

        // Focus the node.
        manager.setFocus(FocusNodeID("a"))
        manager.dispatchKeyToFocused(.keyDown(.enter))
        #expect(fired == 1)
    }

    @Test
    func `unregister stops delivery`() {
        let manager = makeManager(["a"])
        var fired: Int = 0
        let token = manager.registerKeyHandler(node: FocusNodeID("a")) { _ in fired += 1 }
        manager.setFocus(FocusNodeID("a"))

        manager.dispatchKeyToFocused(.keyDown(.enter))
        #expect(fired == 1)

        manager.unregisterKeyHandler(node: FocusNodeID("a"), token: token)
        manager.dispatchKeyToFocused(.keyDown(.enter))
        #expect(fired == 1)
    }

    @Test
    func `router gives the focused handler first dibs and skips navigation when consumed`() {
        let manager = makeManager(["a", "b"])
        manager.setFocus(FocusNodeID("a"))
        let router: FocusKeyboardRouter = .init(manager: manager)

        var fired: Int = 0
        _ = manager.registerKeyHandler(node: FocusNodeID("a")) { event in
            fired += 1
            event.consume()
        }

        // Return is consumed by the focused handler → focus does not move.
        router.handle(.keyDown(.enter))
        #expect(fired == 1)
        #expect(manager.currentFocus == FocusNodeID("a"))
    }

    @Test
    func `router falls through to navigation when the handler does not consume`() {
        let manager = makeManager(["a", "b"])
        manager.setFocus(FocusNodeID("a"))
        let router: FocusKeyboardRouter = .init(manager: manager)

        var seen: Int = 0
        // Handler observes but does not consume.
        _ = manager.registerKeyHandler(node: FocusNodeID("a")) { _ in seen += 1 }

        router.handle(.keyDown(.tab))
        #expect(seen == 1) // the focused handler saw the Tab
        #expect(manager.currentFocus == FocusNodeID("b")) // …and navigation still ran
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
}
