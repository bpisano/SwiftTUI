//
//  EqualityComparator.swift
//  AttributeGraph2
//
//  Created by Benjamin Pisano on 02/04/2026.
//

/// A type-erased, `Sendable` equality comparator.
/// Using a protocol + concrete struct avoids closure captures entirely.
protocol EqualityComparator<Value>: Sendable {
    associatedtype Value
    func isEqual(_ a: Value, _ b: Value) -> Bool
}

/// Concrete comparator for `Equatable` types. Has no stored properties,
/// so it is trivially `Sendable` with no capture warnings.
struct EquatableComparator<Value: Equatable>: EqualityComparator, Sendable {
    func isEqual(_ a: Value, _ b: Value) -> Bool { a == b }
}
