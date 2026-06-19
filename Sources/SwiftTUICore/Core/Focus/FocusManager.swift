//
//  FocusManager.swift
//  SwiftTUICore
//
//  Created by Benjamin Pisano on 21/05/2026.
//

import Foundation
import AttributeGraph
import Terminal

@MainActor
@_documentation(visibility: internal)
public final class FocusManager {
    private let _currentFocus: Attribute<FocusNodeID?>
    private var _map: FocusMap = .init(list: .empty)

    /// Key handlers registered per focusable node, keyed by a registration
    /// token. Only the handlers of the node that currently holds focus are
    /// invoked — focus is checked here, live, at dispatch time, so a handler can
    /// never fire for an unfocused node nor go stale.
    private var keyHandlers: [FocusNodeID: [UUID: @MainActor (Keyboard.Event) -> Void]] = [:]

    public var currentFocus: FocusNodeID? {
        _currentFocus.wrappedValue
    }

    public var map: FocusMap {
        _map
    }

    public var currentFocusAttribute: Attribute<FocusNodeID?> {
        _currentFocus
    }

    public init() {
        self._currentFocus = .init(wrappedValue: nil)
        self._currentFocus.label = "FocusManager.currentFocus"
    }

    public func setFocus(_ id: FocusNodeID?) {
        guard _currentFocus.wrappedValue != id else { return }
        _currentFocus.wrappedValue = id
    }

    public func clearFocus() {
        setFocus(nil)
    }

    public func rebuild(from list: FocusList) {
        _map = FocusMap(list: list)
        if let current = currentFocus, !_map.contains(current) {
            setFocus(nil)
        }
    }

    /// Registers a key handler for `node`. The handler runs only while `node`
    /// holds focus. Returns a token to pass back to ``unregisterKeyHandler``.
    func registerKeyHandler(
        node: FocusNodeID,
        _ handler: @escaping @MainActor (Keyboard.Event) -> Void
    ) -> UUID {
        let token: UUID = .init()
        keyHandlers[node, default: [:]][token] = handler
        return token
    }

    func unregisterKeyHandler(node: FocusNodeID, token: UUID) {
        keyHandlers[node]?.removeValue(forKey: token)
        if keyHandlers[node]?.isEmpty == true {
            keyHandlers[node] = nil
        }
    }

    /// Delivers a key event to the handlers of the node that currently holds
    /// focus. Handlers may consume the event to stop further routing (e.g. focus
    /// navigation). No-op when nothing is focused.
    func dispatchKeyToFocused(_ event: Keyboard.Event) {
        guard let current = currentFocus,
              let handlers = keyHandlers[current] else { return }
        for handler in handlers.values {
            handler(event)
        }
    }

    @discardableResult
    public func move(_ direction: FocusMap.Direction) -> Bool {
        guard let current = currentFocus else {
            return setFocusToFirstIfPossible()
        }
        guard let next = _map.nextFocus(from: current, in: direction) else { return false }
        setFocus(next)
        return true
    }

    @discardableResult
    public func move(_ direction: FocusMap.TabDirection) -> Bool {
        guard let current = currentFocus else {
            switch direction {
            case .next:
                return setFocusToFirstIfPossible()
            case .previous:
                if let last = _map.lastNode {
                    setFocus(last)
                    return true
                }
                return false
            }
        }
        guard let next = _map.nextFocus(from: current, in: direction) else { return false }
        setFocus(next)
        return true
    }

    @discardableResult
    private func setFocusToFirstIfPossible() -> Bool {
        guard let first = _map.firstNode else { return false }
        setFocus(first)
        return true
    }
}
