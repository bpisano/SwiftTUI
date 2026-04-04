//
//  Layout.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 10/03/2026.
//

import Foundation
import Geometry

public protocol Layout {
    associatedtype Cache = Void

    typealias Subview = LayoutProxy

    func makeCache(subviews: [Subview]) -> Cache

    func updateCache(
        _ cache: inout Cache,
        subviews: [Subview]
    )

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: [Subview],
        cache: inout Cache
    ) -> Size

    func placeSubviews(
        in bounds: Rect,
        subviews: [Subview],
        cache: inout Cache
    )
}

extension Layout {
    @MainActor
    public func callAsFunction<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        LayoutView(layout: self, content: content())
    }

    @MainActor
    func layoutComputer(for subviews: [LayoutComputer]) -> LayoutComputer {
        LayoutEngine(layout: self, subviews: subviews).makeLayoutComputer()
    }
}

extension Layout where Cache == Void {
    public func makeCache(subviews: [Subview]) -> Void { () }

    public func updateCache(_ cache: inout Void, subviews: [Subview]) {}
}
