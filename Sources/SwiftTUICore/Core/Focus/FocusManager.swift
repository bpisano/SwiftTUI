//
//  FocusManager.swift
//  SwiftTUICore
//
//  Created by Benjamin Pisano on 2026-05-21.
//

import Foundation
import AttributeGraph

@MainActor
public final class FocusManager {
    private let _currentFocus: Attribute<FocusNodeID?>
    private var _map: FocusMap = .init(list: .empty)

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
