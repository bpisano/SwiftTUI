//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 24/12/2025.
//

import AttributeGraph
import Foundation
import Geometry

public struct VStack<Content: View>: PrimitiveView, LayoutView {
    let layout: VStackLayout
    let content: Content

    public init(
        alignment: HorizontalAlignment = .center,
        @ViewBuilder content: () -> Content
    ) {
        self.layout = VStackLayout(alignment: alignment)
        self.content = content()
    }
}

extension VStack: CustomStringConvertible {
    public var description: String {
        "VStack"
    }
}
