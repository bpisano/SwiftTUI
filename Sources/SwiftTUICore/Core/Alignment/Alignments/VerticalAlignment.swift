//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 02/12/2025.
//

import Foundation

public struct VerticalAlignment: AlignmentGuide, Sendable {
    public let key: AlignmentKey

    public init(_ id: any AlignmentID.Type) {
        self.key = AlignmentKey(id: id, axis: .vertical)
    }
}

extension VerticalAlignment {
    public static func == (lhs: VerticalAlignment, rhs: VerticalAlignment) -> Bool {
        lhs.key == rhs.key
    }
}

extension VerticalAlignment {
    public static let top = VerticalAlignment(TopAlignmentID.self)
    public static let center = VerticalAlignment(CenterAlignmentID.self)
    public static let bottom = VerticalAlignment(BottomAlignmentID.self)

    private struct TopAlignmentID: AlignmentID {
        static func defaultValue(in context: ViewDimensions) -> Double {
            0
        }
    }

    private struct CenterAlignmentID: AlignmentID {
        static func defaultValue(in context: ViewDimensions) -> Double {
            context.size.height / 2
        }
    }

    private struct BottomAlignmentID: AlignmentID {
        static func defaultValue(in context: ViewDimensions) -> Double {
            context.size.height
        }
    }
}

extension VerticalAlignment: CustomStringConvertible {
    public var description: String {
        switch key.id {
        case is TopAlignmentID.Type:
            return ".top"
        case is CenterAlignmentID.Type:
            return ".center"
        case is BottomAlignmentID.Type:
            return ".bottom"
        default:
            return "VerticalAlignment<\(key.id)>"
        }
    }
}
