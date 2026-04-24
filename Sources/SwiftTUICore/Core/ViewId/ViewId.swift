//
//  ViewId.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 05/04/2026.
//

import Foundation
import AttributeGraph

struct ViewId: Hashable, Equatable, Sendable {
    /// The index of the view in the view hierarchy, starting from 0 for the root view.
    /// Example:
    /// ```
    /// VStack {
    ///     Text("Hello") // implicitId: 0
    ///     HStack {
    ///         Text("World") // implicitId: 1
    ///     }
    /// }
    /// ```
    let implicitId: Int

    /// Secondary position information within the current implicit scope.
    ///
    /// For static children this often mirrors the local sibling slot.
    /// For dynamic children it stores the leaf position that remains after
    /// explicit identity is rebound by containers like `ForEach`.
    let index: Int

    var explicit: [Explicit] = []

    init(
        implicitId: Int,
        index: Int = 0,
        explicit: [Explicit] = []
    ) {
        self.implicitId = implicitId
        self.index = index
        self.explicit = explicit
    }
}

extension ViewId {
    struct Explicit: Hashable, Equatable, @unchecked Sendable {
        let id: AnyHashable
    }

    struct Scope: Hashable, Equatable, Sendable {
        let implicitId: Int
    }
}
