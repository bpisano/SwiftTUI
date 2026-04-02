//
//  File.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 21/03/2026.
//

import Foundation

/// Three-state dirty system.
///
/// - `.clean`: value is current, no re-evaluation needed.
/// - `.pending`: a transitive ancestor changed, but no direct dependency has confirmed a change yet.
///   Re-evaluate only if at least one direct dependency actually changed its value.
/// - `.dirty`: a direct dependency confirmed changed, or the value was written externally.
///   Must re-evaluate unconditionally.
public enum AttributeState: Int8, Hashable, Equatable, Codable, Sendable {
    case clean
    case pending
    case dirty
}
