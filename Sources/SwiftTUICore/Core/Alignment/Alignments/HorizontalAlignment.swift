//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 02/12/2025.
//

import Foundation

struct HorizontalAlignment: @MainActor AlignmentGuide {
    let key: AlignmentKey

    init(_ id: AlignmentID.Type) {
        self.key = AlignmentKey(id: id, axis: .horizontal)
    }
}

extension HorizontalAlignment {
    static func == (lhs: HorizontalAlignment, rhs: HorizontalAlignment) -> Bool {
        lhs.key == rhs.key
    }
}

extension HorizontalAlignment {
    static let leading: HorizontalAlignment = .init(LeadingAlignment.self)
    static let center: HorizontalAlignment = .init(CenterAlignment.self)
    static let trailing: HorizontalAlignment = .init(TrailingAlignment.self)

    private struct LeadingAlignment: AlignmentID {
        static func defaultValue(in context: ViewDimensions) -> Double {
            0
        }
    }

    private struct CenterAlignment: AlignmentID {
        static func defaultValue(in context: ViewDimensions) -> Double {
            context.size.width / 2
        }
    }

    private struct TrailingAlignment: AlignmentID {
        static func defaultValue(in context: ViewDimensions) -> Double {
            context.size.width
        }
    }
}

extension HorizontalAlignment: CustomStringConvertible {
    var description: String {
        switch self {
        case .leading:
            return ".leading"
        case .center:
            return ".center"
        case .trailing:
            return ".trailing"
        default:
            return "HorizontalAlignment<\(ObjectIdentifier(key.id))>"
        }
    }
}
