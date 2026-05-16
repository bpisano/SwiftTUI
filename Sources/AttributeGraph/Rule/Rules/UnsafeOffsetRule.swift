//
//  UnsafeOffsetRule.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 27/12/2025.
//

import Foundation

public struct UnsafeOffsetRule<T, U>: Rule {
    let parent: Attribute<T>
    let offset: Int

    public func evaluate() -> U {
        withUnsafePointer(to: parent.wrappedValue) { ptr in
            let rawPtr = UnsafeRawPointer(ptr)
            let offsetPtr = rawPtr.advanced(by: offset)
            let typedPtr = offsetPtr.assumingMemoryBound(to: U.self)
            return typedPtr.pointee
        }
    }
}

extension Attribute {
    public func unsafeOffset<U>(at offset: Int, as type: U.Type) -> Attribute<U> {
        Attribute<U>(rule: UnsafeOffsetRule(parent: self, offset: offset))
    }
}
