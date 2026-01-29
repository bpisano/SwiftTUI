//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 02/12/2025.
//

import Foundation
import Geometry

public struct ViewDimensions {
    static let zero: ViewDimensions = .init(origin: .zero, size: .zero)

    public let origin: Point
    public let size: Size

    public var frame: Rect {
        Rect(origin: origin, size: size)
    }

    private var alignments: [AlignmentKey: CGFloat] = [:]

    init(origin: Point, size: Size) {
        self.origin = origin
        self.size = size
    }

    init(frame: Rect) {
        self.origin = frame.origin
        self.size = frame.size
    }

    subscript(guide: HorizontalAlignment) -> CGFloat {
        alignments[guide.key] ?? guide.key.id.defaultValue(in: self)
    }

    subscript(guide: VerticalAlignment) -> CGFloat {
        alignments[guide.key] ?? guide.key.id.defaultValue(in: self)
    }
}

extension ViewDimensions: CustomStringConvertible {
    public var description: String {
        "(\(origin.x), \(origin.y), \(size.width), \(size.height))"
    }
}
