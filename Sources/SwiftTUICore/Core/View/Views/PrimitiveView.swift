//
//  PrimitiveView.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 27/01/2026.
//

import Foundation

protocol PrimitiveView: View where Body == Never {}

extension PrimitiveView {
    public var body: Never {
        fatalError("PrimitiveView doesn't have a body")
    }
}

extension Never: View {
    public var body: some View {
        fatalError("Never doesn't have a body")
    }
}
