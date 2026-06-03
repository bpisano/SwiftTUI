//
//  FrameViewModifier.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 10/03/2026.
//

import AttributeGraph
import Foundation
import Geometry

struct FrameViewModifier: ViewModifier, PrimitiveViewModifier, UnaryViewModifier, LayoutViewModifier {
    private let width: GeometryUnit?
    private let height: GeometryUnit?
    private let alignment: Alignment

    init(
        width: GeometryUnit?,
        height: GeometryUnit?,
        alignment: Alignment
    ) {
        self.width = width
        self.height = height
        self.alignment = alignment
    }
}

extension FrameViewModifier {
    static func makeLayout(
        _ modifier: Attribute<Self>,
        inputs: ViewInputs
    ) -> any Layout {
        let modifier: Self = modifier.wrappedValue
        return FrameLayout(
            width: modifier.width,
            height: modifier.height,
            alignment: modifier.alignment
        )
    }
}

extension View {
    /// Positions this view within an invisible frame of the given size.
    ///
    /// An omitted (`nil`) dimension is sized to fit the content. When a fixed
    /// dimension is larger than the content, the content is positioned using
    /// `alignment`.
    ///
    /// ```swift
    /// Text("Hello")
    ///     .frame(width: 20, height: 3, alignment: .leading)
    /// ```
    ///
    /// - Parameters:
    ///   - width: A fixed width for the frame, or `nil` to size to content.
    ///   - height: A fixed height for the frame, or `nil` to size to content.
    ///   - alignment: How to align the content inside the frame. Defaults to
    ///     `.center`.
    public func frame(
        width: GeometryUnit? = nil,
        height: GeometryUnit? = nil,
        alignment: Alignment = .center
    ) -> some View {
        modifier(
            FrameViewModifier(
                width: width,
                height: height,
                alignment: alignment
            )
        )
    }
}
