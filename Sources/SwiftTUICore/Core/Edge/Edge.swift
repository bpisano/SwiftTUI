//
//  File.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 29/03/2026.
//

import Foundation

@frozen
public enum Edge: Int8, CaseIterable, Hashable, Equatable, Codable, Sendable {
    case top
    case leading
    case bottom
    case trailing
}

extension Edge {
    @frozen
    public struct Set: OptionSet, Hashable, Equatable, Codable, Sendable {
        public typealias Element = Set

        public static let top: Set = .init(.top)
        public static let leading: Set = .init(.leading)
        public static let bottom: Set = .init(.bottom)
        public static let trailing: Set = .init(.trailing)
        public static let vertical: Set = [.top, .bottom]
        public static let horizontal: Set = [.leading, .trailing]

        public static let all: Set = [.top, .leading, .bottom, .trailing]

        public let rawValue: UInt8

        public init(rawValue: UInt8) {
            self.rawValue = rawValue
        }

        public init(_ edge: Edge) {
            self.rawValue = 1 << edge.rawValue
        }

        func contains(_ edge: Edge) -> Bool {
            contains(.init(edge))
        }
    }
}
