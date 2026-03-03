//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 23/02/2026.
//

import Foundation

struct ExplicitIdInput: ViewInputKey {
    typealias Value = [ViewId.Explicit]
}

extension ViewInputs {
    func currentExplicitIds() -> [ViewId.Explicit] {
        storage[ExplicitIdInput.self] ?? []
    }
}

extension ViewListInputs {
    func currentExplicitIds() -> [ViewId.Explicit] {
        storage[ExplicitIdInput.self] ?? []
    }
}
