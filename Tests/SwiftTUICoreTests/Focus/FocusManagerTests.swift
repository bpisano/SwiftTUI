//
//  FocusManagerTests.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 2026-05-21.
//

import Foundation
import Geometry
import Testing

@testable import SwiftTUICore

@Suite("FocusManager")
@MainActor
struct FocusManagerTests {
    private func node(_ name: String, x: Double, y: Double) -> FocusableNode {
        FocusableNode(id: FocusNodeID(name), frame: Rect(x: x, y: y, width: 10, height: 1))
    }

    @Test
    func `Initial focus is nil`() {
        let manager = FocusManager()
        #expect(manager.currentFocus == nil)
    }

    @Test
    func `First tab next focuses first node`() {
        let manager = FocusManager()
        manager.rebuild(from: FocusList(
            .node(node("a", x: 0, y: 0)),
            .node(node("b", x: 0, y: 2))
        ))
        #expect(manager.move(.next) == true)
        #expect(manager.currentFocus == FocusNodeID("a"))
    }

    @Test
    func `First tab previous focuses last node`() {
        let manager = FocusManager()
        manager.rebuild(from: FocusList(
            .node(node("a", x: 0, y: 0)),
            .node(node("b", x: 0, y: 2))
        ))
        #expect(manager.move(.previous) == true)
        #expect(manager.currentFocus == FocusNodeID("b"))
    }

    @Test
    func `Tab next cycles`() {
        let manager = FocusManager()
        manager.rebuild(from: FocusList(
            .node(node("a", x: 0, y: 0)),
            .node(node("b", x: 0, y: 2))
        ))
        manager.setFocus(FocusNodeID("a"))
        manager.move(.next)
        #expect(manager.currentFocus == FocusNodeID("b"))
        manager.move(.next)
        #expect(manager.currentFocus == FocusNodeID("a"))
    }

    @Test
    func `Spatial down moves focus`() {
        let manager = FocusManager()
        manager.rebuild(from: FocusList(
            .node(node("a", x: 0, y: 0)),
            .node(node("b", x: 0, y: 2))
        ))
        manager.setFocus(FocusNodeID("a"))
        #expect(manager.move(.down) == true)
        #expect(manager.currentFocus == FocusNodeID("b"))
    }

    @Test
    func `setFocus sets and clearFocus clears`() {
        let manager = FocusManager()
        manager.rebuild(from: FocusList(.node(node("a", x: 0, y: 0))))
        manager.setFocus(FocusNodeID("a"))
        #expect(manager.currentFocus == FocusNodeID("a"))
        manager.clearFocus()
        #expect(manager.currentFocus == nil)
    }

    @Test
    func `Rebuild that removes current focus clears it`() {
        let manager = FocusManager()
        manager.rebuild(from: FocusList(
            .node(node("a", x: 0, y: 0)),
            .node(node("b", x: 0, y: 2))
        ))
        manager.setFocus(FocusNodeID("a"))
        manager.rebuild(from: FocusList(.node(node("b", x: 0, y: 2))))
        #expect(manager.currentFocus == nil)
    }

    @Test
    func `Move returns false when no candidate`() {
        let manager = FocusManager()
        manager.rebuild(from: FocusList(.node(node("a", x: 0, y: 0))))
        manager.setFocus(FocusNodeID("a"))
        #expect(manager.move(.up) == false)
        #expect(manager.currentFocus == FocusNodeID("a"))
    }
}
