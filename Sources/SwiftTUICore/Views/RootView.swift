//
//  RootView.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 29/01/2026.
//

import AttributeGraph
import Foundation
import Geometry

public struct RootView<Content: View>: UnaryView, PrimitiveView, LayoutView {
    let layout: RootLayout = .init()
    let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
}

extension RootView: CustomStringConvertible {
    public var description: String {
        "RootView"
    }
}
