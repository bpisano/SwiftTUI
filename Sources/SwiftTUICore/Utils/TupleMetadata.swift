//
//  TupleMetadata.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 10/03/2026.
//

import Foundation

/// Internal representation of tuple metadata structure.
///
/// This struct mirrors the first two fields of Swift's tuple metadata layout.
/// It's used for an alternative (currently unused) approach to reading tuple information
/// through structured access rather than pointer arithmetic.
///
/// - Note: The methods in this struct are not currently used by `TupleType`.
struct TupleMetadata {
    /// The kind of type metadata (identifies this as a tuple).
    let kind: Int
    /// The number of elements in the tuple.
    let numElements: Int

    /// Alternative implementation: Returns the type at the specified index.
    ///
    /// This method uses structured access through the `TupleMetadata` layout.
    /// It navigates past:
    /// 1. The TupleMetadata header (kind + numElements)
    /// 2. The labels pointer (Int)
    /// 3. Then reads from the array of type pointers
    ///
    /// - Parameter index: The zero-based index of the element
    /// - Returns: The type of the element
    func elementType(at index: Int) -> Any.Type {
        // Start from the address of this struct and navigate past the header
        let baseAddress: UnsafeRawPointer = withUnsafePointer(to: self) { ptr in
            let base: UnsafeRawPointer = .init(ptr)
            return base
                .advanced(by: MemoryLayout<TupleMetadata>.size)  // Skip kind + numElements
                .advanced(by: MemoryLayout<Int>.size)  // Skip labels pointer
        }

        // Read the type pointer from the array
        let typeAddress: UnsafeRawPointer = baseAddress.advanced(by: index * MemoryLayout<Int>.size)
        let typePointer: Int = typeAddress.load(as: Int.self)
        let type: Any.Type = unsafeBitCast(typePointer, to: Any.Type.self)
        return type
    }

    /// Alternative implementation: Returns the byte offset at the specified index.
    ///
    /// This navigates to the offset array, which comes after the type pointer array.
    /// Memory layout:
    /// 1. TupleMetadata header (kind + numElements)
    /// 2. Labels pointer (Int)
    /// 3. Array of type pointers (numElements * 8 bytes)
    /// 4. Array of offsets (numElements * 4 bytes)
    ///
    /// - Parameter index: The zero-based index of the element
    /// - Returns: The byte offset from the start of a tuple instance
    func elementOffset(at index: Int) -> Int {
        // Navigate past the header, labels, and all type pointers to reach the offsets array
        let baseAddress: UnsafeRawPointer = withUnsafePointer(to: self) { ptr in
            UnsafeRawPointer(ptr)
                .advanced(by: MemoryLayout<TupleMetadata>.size)  // Skip kind + numElements
                .advanced(by: MemoryLayout<Int>.size)  // Skip labels pointer
                .advanced(by: numElements * MemoryLayout<Int>.size)  // Skip all type pointers
        }

        // Read the offset as UInt32 from the offsets array
        let advancedOffset: Int = index * MemoryLayout<UInt32>.size
        let offsetAddress: UnsafeRawPointer = baseAddress.advanced(by: advancedOffset)
        let offset: UInt32 = offsetAddress.load(as: UInt32.self)

        return Int(offset)
    }
}
