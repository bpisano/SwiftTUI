//
//  ViewId.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 05/04/2026.
//

import Foundation
import AttributeGraph

struct ViewId: Hashable, Equatable {
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

    /// The index of the view among its siblings, starting from 0 for the first sibling.
    /// Example:
    /// ```
    /// ForEach(users) { user in
    ///    Text(user.name)
    /// }
    /// // Text("Alice") -> implicitId: 0, index: 0
    /// // Text("Bob") -> implicitId: 0, index: 1
    /// ```
    let index: Int

    var explicit: [Explicit] = []

    init(
        implicitId: Int,
        index: Int = 0,
    ) {
        self.implicitId = implicitId
        self.index = index
    }
}

extension ViewId {
    struct Explicit: Hashable, Equatable {
        let id: AnyHashable
    }
}
