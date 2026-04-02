//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 29/01/2026.
//

import Foundation

public struct AttributeFlags: OptionSet, Sendable {
    public static let transactional: AttributeFlag = .init(rawValue: 1 << 0)

    public let rawValue: UInt8

    public init(rawValue: UInt8) {
        self.rawValue = rawValue
    }

}

public typealias AttributeFlag = AttributeFlags
