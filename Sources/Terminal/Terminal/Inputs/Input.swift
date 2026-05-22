//
//  Input.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 29/01/2026.
//

import Foundation
import Synchronization

public protocol Input: Sendable {
    associatedtype Event: Sendable

    @InputActor
    func events() -> AsyncStream<Event>

    /// Registers a synchronous handler invoked on `MainActor` for each input
    /// event. Returns an opaque subscription whose `cancel()` removes the
    /// handler; cancellation also fires on deinit.
    @MainActor
    func subscribe(
        handler: @escaping @MainActor @Sendable (Event) -> Void
    ) -> InputSubscription
}

public final class InputSubscription: Sendable {
    private let cancelAction: @Sendable () -> Void
    private let cancelled: Mutex<Bool> = .init(false)

    public init(_ cancel: @escaping @Sendable () -> Void) {
        self.cancelAction = cancel
    }

    deinit {
        cancel()
    }

    public func cancel() {
        let shouldCancel: Bool = cancelled.withLock { state in
            guard !state else { return false }
            state = true
            return true
        }
        if shouldCancel {
            cancelAction()
        }
    }
}
