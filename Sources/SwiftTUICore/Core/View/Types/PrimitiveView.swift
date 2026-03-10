//
//  File.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 10/03/2026.
//

import Foundation

/// A view that doesn't have a body.
protocol PrimitiveView: View where Body == Never {}

extension PrimitiveView {
    public var body: Never {
        fatalError("PrimitiveView doesn't have a body")
    }
}
