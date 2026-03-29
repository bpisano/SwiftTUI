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
    ) -> Layout {
        let modifier: Self = modifier.wrappedValue
        return FrameLayout(
            width: modifier.width,
            height: modifier.height,
            alignment: modifier.alignment
        )
    }
}

extension View {
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
