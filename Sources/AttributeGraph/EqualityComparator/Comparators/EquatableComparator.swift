//
//  EquatableComparator.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 02/04/2026.
//

import Foundation

struct EquatableComparator<Value: Equatable>: EqualityComparator {
    func isEqual(_ a: Value, _ b: Value) -> Bool {
        a == b
    }
}
