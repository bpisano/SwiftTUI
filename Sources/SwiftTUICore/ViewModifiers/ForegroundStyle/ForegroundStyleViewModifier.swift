//
//  File.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 14/04/2026.
//

import Foundation

extension View {
    /// Sets the foreground style used to render this view's content.
    ///
    /// The style applies to text and other foreground content in this view and
    /// its subviews. Pass a ``Color`` or any other ``ShapeStyle``.
    ///
    /// ```swift
    /// Text("Hello")
    ///     .foregroundStyle(Color.green)
    /// ```
    ///
    /// - Parameter style: The ``ShapeStyle`` to use for foreground content.
    public func foregroundStyle<S: ShapeStyle>(_ style: S) -> some View {
        environment(\.foregroundStyle, AnyShapeStyle(style))
    }
}

struct ForegroundStyleEnvironmentKey: EnvironmentKey {
    nonisolated(unsafe) static let defaultValue: AnyShapeStyle = AnyShapeStyle(Color.white)
}

extension EnvironmentValues {
    var foregroundStyle: AnyShapeStyle {
        get { self[ForegroundStyleEnvironmentKey.self] }
        set { self[ForegroundStyleEnvironmentKey.self] = newValue }
    }
}
