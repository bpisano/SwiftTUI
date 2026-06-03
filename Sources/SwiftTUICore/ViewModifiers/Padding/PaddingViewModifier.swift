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
    /// Adds space around the view on all edges.
    ///
    /// ```swift
    /// Text("Hello")
    ///     .padding(2)
    /// ```
    ///
    /// - Parameter length: The amount of space to add on each edge.
    public func padding(
        _ length: GeometryUnit
    ) -> some View {
        modifier(PaddingViewModifier(edges: .all, length: length))
    }

    /// Adds space around the view on the given edges.
    ///
    /// - Parameters:
    ///   - edges: The set of edges to pad.
    ///   - length: The amount of space to add on each given edge.
    public func padding(
        _ edges: Edge.Set,
        _ length: GeometryUnit
    ) -> some View {
        modifier(PaddingViewModifier(edges: edges, length: length))
    }

    /// Adds one unit of space around the view on the given edges.
    ///
    /// - Parameter edges: The set of edges to pad.
    public func padding(
        _ edges: Edge.Set
    ) -> some View {
        modifier(PaddingViewModifier(edges: edges, length: 1))
    }

    /// Adds one unit of space around the view on all edges.
    public func padding() -> some View {
        modifier(PaddingViewModifier(edges: .all, length: 1))
    }
}
