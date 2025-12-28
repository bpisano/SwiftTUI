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
        // Get the parent's value
        let parentValue = parent.wrappedValue
        
        // Use withUnsafePointer to access the memory at the specified offset
        return withUnsafePointer(to: parentValue) { ptr in
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
