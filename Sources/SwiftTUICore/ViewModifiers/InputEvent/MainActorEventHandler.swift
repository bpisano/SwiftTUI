//
//  MainActorEventHandler.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 26/04/2026.
//

import Foundation

final class MainActorEventHandler<Event: Sendable>: Sendable {
    private let action: @MainActor @Sendable (Event) -> Void

    init(_ action: @escaping @MainActor @Sendable (Event) -> Void) {
        self.action = action
    }

    @MainActor
    func callAsFunction(_ event: Event) {
        action(event)
    }
}
