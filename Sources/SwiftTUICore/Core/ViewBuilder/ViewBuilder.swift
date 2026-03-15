//
//  File.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 15/03/2026.
//

import Foundation

@resultBuilder
public enum ViewBuilder {
    public static func buildBlock() -> some View {
        EmptyView()
    }

    public static func buildBlock<V: View>(_ component: V) -> some View {
        component
    }

    public static func buildBlock<each V: View>(_ components: repeat each V) -> some View {
        TupleView(repeat each components)
    }
}
