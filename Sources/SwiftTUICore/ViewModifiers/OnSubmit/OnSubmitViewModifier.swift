//
//  OnSubmitViewModifier.swift
//  SwiftTUICore
//
//  Created by Benjamin Pisano on 21/05/2026.
//

import Foundation
import AttributeGraph

struct OnSubmitEnvironmentKey: EnvironmentKey {
    static let defaultValue: SubmitAction? = nil
}

public struct SubmitAction: @unchecked Sendable {
    private let action: @MainActor () -> Void

    init(_ action: @escaping @MainActor () -> Void) {
        self.action = action
    }

    @MainActor
    public func callAsFunction() {
        action()
    }
}

extension EnvironmentValues {
    public var submitAction: SubmitAction? {
        get { self[OnSubmitEnvironmentKey.self] }
        set { self[OnSubmitEnvironmentKey.self] = newValue }
    }
}

extension View {
    public func onSubmit(_ action: @escaping @MainActor () -> Void) -> some View {
        environment(\.submitAction, SubmitAction(action))
    }
}
