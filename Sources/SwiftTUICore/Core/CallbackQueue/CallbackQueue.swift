//
//  CallbackQueue.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 29/01/2026.
//

import Foundation

@MainActor
public final class CallbackQueue {
    public static let shared: CallbackQueue = .init()

    private var callbacks: [() -> Void] = []

    private init() {}

    func enqueue(_ callback: @escaping () -> Void) {
        callbacks.append(callback)
    }

    public func executeAll() {
        let currentCallbacks = callbacks
        callbacks.removeAll()
        for callback in currentCallbacks {
            callback()
        }
    }
}
