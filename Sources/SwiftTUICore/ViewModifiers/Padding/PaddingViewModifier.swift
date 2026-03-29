//
//  File.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 29/03/2026.
//

import Foundation
import AttributeGraph
import Geometry

struct PaddingViewModifier: ViewModifier, PrimitiveViewModifier, UnaryViewModifier, LayoutViewModifier {
    let edges: Edge.Set
    let length: GeometryUnit
}

extension PaddingViewModifier {
    static func makeLayout(
        _ modifier: Attribute<Self>,
        inputs: ViewInputs
    ) -> any Layout {
        let modifier: Self = modifier.wrappedValue
        return PaddingLayout(
            edges: modifier.edges,
            length: modifier.length
        )
    }
}

extension View {
    public func padding(
        _ length: GeometryUnit
    ) -> some View {
        modifier(PaddingViewModifier(edges: .all, length: length))
    }

    public func padding(
        _ edges: Edge.Set,
        _ length: GeometryUnit
    ) -> some View {
        modifier(PaddingViewModifier(edges: edges, length: length))
    }

    public func padding(
        _ edges: Edge.Set
    ) -> some View {
        modifier(PaddingViewModifier(edges: edges, length: 1))
    }

    public func padding() -> some View {
        modifier(PaddingViewModifier(edges: .all, length: 1))
    }
}
