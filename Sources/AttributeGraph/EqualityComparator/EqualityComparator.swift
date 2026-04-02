//
//  EqualityComparator.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 02/04/2026.
//

import Foundation

protocol EqualityComparator<Value>: Sendable {
    associatedtype Value

    func isEqual(_ a: Value, _ b: Value) -> Bool
}

