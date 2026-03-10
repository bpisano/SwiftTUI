//
//  PrimitiveViewModifier.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 10/03/2026.
//

import Foundation

/// A ViewModifier that doesn't have a body.
protocol PrimitiveViewModifier: ViewModifier where Body == Never {}

extension PrimitiveViewModifier {
    func body(content: Content) -> Never {
        fatalError("PrimitiveViewModifier doesn't have a body")
    }
}
