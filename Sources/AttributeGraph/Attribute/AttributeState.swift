//
//  File.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 21/03/2026.
//

import Foundation

public enum AttributeState: Int8, Hashable, Equatable, Codable, Sendable {
    case clean
    case potentiallyDirty
}
