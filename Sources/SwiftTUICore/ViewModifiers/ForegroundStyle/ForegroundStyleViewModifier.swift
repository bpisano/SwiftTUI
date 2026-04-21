//
//  File.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 14/04/2026.
//

import Foundation

extension View {
    public func foregroundStyle<S: ShapeStyle>(_ style: S) -> some View {
        environment(\.foregroundStyle, AnyShapeStyle(style))
    }
}

struct ForegroundStyleEnvironmentKey: EnvironmentKey {
    static let defaultValue: AnyShapeStyle = AnyShapeStyle(Color.white)
}

extension EnvironmentValues {
    var foregroundStyle: AnyShapeStyle {
        get { self[ForegroundStyleEnvironmentKey.self] }
        set { self[ForegroundStyleEnvironmentKey.self] = newValue }
    }
}
