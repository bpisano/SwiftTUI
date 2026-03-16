//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 02/12/2025.
//

import Foundation

struct VerticalAlignment: @MainActor AlignmentGuide {
    let key: AlignmentKey

    init(_ id: any AlignmentID.Type) {
        self.key = AlignmentKey(id: id, axis: .vertical)
    }
}

extension VerticalAlignment {
    static func == (lhs: VerticalAlignment, rhs: VerticalAlignment) -> Bool {
        lhs.key == rhs.key
    }
}

extension VerticalAlignment {
    static let top = VerticalAlignment(TopAlignmentID.self)
    static let center = VerticalAlignment(CenterAlignmentID.self)
    static let bottom = VerticalAlignment(BottomAlignmentID.self)

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
    var description: String {
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
