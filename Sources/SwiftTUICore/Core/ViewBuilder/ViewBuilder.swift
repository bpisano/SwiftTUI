//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 24/12/2025.
//

import Foundation

@resultBuilder
public struct ViewBuilder {
    public static func buildBlock<V: View>(_ component: V) -> some View {
        component
    }

    public static func buildBlock<each V: View>(_ components: repeat each V) -> some View {
        TupleView(repeat each components)
    }
}
