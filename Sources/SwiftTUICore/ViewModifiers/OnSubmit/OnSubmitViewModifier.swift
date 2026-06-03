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
    /// Runs an action when a submit-capable view in this subtree is submitted.
    ///
    /// Controls such as ``TextField`` trigger this when the user submits, for
    /// example by pressing Return. The action is stored in
    /// ``EnvironmentValues/submitAction`` and runs on the main actor.
    ///
    /// ```swift
    /// TextField("Name", text: $name)
    ///     .onSubmit {
    ///         save(name)
    ///     }
    /// ```
    ///
    /// - Parameter action: A closure to run on submit.
    public func onSubmit(_ action: @escaping @MainActor () -> Void) -> some View {
        environment(\.submitAction, SubmitAction(action))
    }
}
