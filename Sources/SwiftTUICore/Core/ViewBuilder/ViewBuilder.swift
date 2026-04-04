//
//  File.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 15/03/2026.
//

import Foundation

@MainActor
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

    // MARK: - Conditional Views

    public static func buildEither<TrueContent: View, FalseContent: View>(
        first component: TrueContent
    ) -> ConditionalView<TrueContent, FalseContent> {
        .init(.trueContent(component))
    }

    public static func buildEither<TrueContent: View, FalseContent: View>(
        second component: FalseContent
    ) -> ConditionalView<TrueContent, FalseContent> {
        .init(.falseContent(component))
    }
}
