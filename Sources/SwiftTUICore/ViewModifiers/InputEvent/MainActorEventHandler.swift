//
//  MainActorEventHandler.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 26/04/2026.
//

import Foundation

final class MainActorEventHandler<Event: Sendable>: @unchecked Sendable {
    private let action: @MainActor (Event) -> Void

    init(_ action: @escaping @MainActor (Event) -> Void) {
        self.action = action
    }

    @MainActor
    func callAsFunction(_ event: Event) {
        action(event)
    }
}
