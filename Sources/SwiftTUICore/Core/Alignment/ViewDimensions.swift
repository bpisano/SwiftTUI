//
//  ViewDimensions.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 16/03/2026.
//

import Foundation
import Geometry

@_documentation(visibility: internal)
public struct ViewDimensions: Sendable {
    public let size: Size

    public init(size: Size) {
        self.size = size
    }
}
