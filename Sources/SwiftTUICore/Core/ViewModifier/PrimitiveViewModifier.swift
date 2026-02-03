//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 02/02/2026.
//

import Foundation

protocol PrimitiveViewModifier: ViewModifier where Body == Never {}

extension PrimitiveViewModifier {
    func body(content: Content) -> Never {
        fatalError("PrimitiveViewModifier doesn't have a body")
    }
}
