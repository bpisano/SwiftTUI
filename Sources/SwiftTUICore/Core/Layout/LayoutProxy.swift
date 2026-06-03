//
//  LayoutProxy.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 10/03/2026.
//

import Foundation
import Geometry

@_documentation(visibility: internal)
public struct LayoutProxy {
    /// Lazily resolves the layout computer. Reading is deferred to the moment
    /// `sizeThatFits` is called, which mirrors OpenSwiftUI's `LayoutProxy`
    /// reading child attributes via `context[layoutComputer]` rather than
    /// capturing a resolved value at construction time.
    private let computerProvider: () -> LayoutComputer
    private let place: (Rect) -> Void

    init(
        computerProvider: @escaping () -> LayoutComputer,
        place: @escaping (_ rect: Rect) -> Void
    ) {
        self.computerProvider = computerProvider
        self.place = place
    }

    public func size(in proposal: ProposedViewSize) -> Size {
        computerProvider().sizeThatFits(proposal)
    }

    public func place(in rect: Rect) {
        place(rect)
    }
}
