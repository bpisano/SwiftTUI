//
//  TupleType.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 10/03/2026.
//

import Foundation

/// A utility for introspecting Swift tuple types at runtime.
///
/// This struct provides access to tuple metadata stored in Swift's runtime type system.
/// It uses unsafe pointer operations to read the internal memory layout of tuple type metadata,
/// which follows a specific structure in the Swift ABI.
///
/// **Memory Layout of Tuple Metadata:**
/// - Offset 0: Kind (Int) - identifies the type as a tuple
/// - Offset 8: Number of elements (Int)
/// - Offset 16: Labels pointer (Int) - optional string labels for tuple elements
/// - Offset 24+: Array of element descriptors, each containing:
///   - Type metadata pointer (8 bytes)
///   - Element offset in bytes (4 bytes as UInt32, with 4 bytes padding)
///
/// **Warning:** This code relies on Swift's internal ABI and may break in future Swift versions.
struct TupleType {
    /// Raw pointer to the tuple's metadata structure in memory.
    private let metadata: UnsafeRawPointer

    /// Creates a tuple type inspector for the given type.
    ///
    /// - Parameter type: The tuple type to inspect (e.g., `(Int, String, Bool).self`)
    ///
    /// This initializer converts the type metadata into a raw pointer that can be used
    /// to read the tuple's internal structure. The `unsafeBitCast` reinterprets the
    /// type value (which is itself a pointer to metadata) as a raw memory address.
    init(_ type: Any.Type) {
        self.metadata = unsafeBitCast(type, to: UnsafeRawPointer.self)
    }

    /// The number of elements in the tuple.
    ///
    /// Reads the element count from offset 8 in the metadata structure.
    /// This is the second field in the tuple metadata layout (after the kind field at offset 0).
    var count: Int {
        metadata.advanced(by: MemoryLayout<Int>.size).load(as: Int.self)
    }

    /// Returns the type of the tuple element at the specified index.
    ///
    /// - Parameter index: The zero-based index of the element
    /// - Returns: The type of the element (e.g., `Int.self`, `String.self`)
    ///
    /// **Implementation Details:**
    /// - Element descriptors start at byte offset 24 (after kind, numElements, and labels pointer)
    /// - Each element descriptor is 16 bytes: 8-byte type pointer + 4-byte offset + 4-byte padding
    /// - To access element N: base + 24 + (N * 16) gives us the type pointer
    /// - The type pointer is then cast back to `Any.Type` using `unsafeBitCast`
    func type(at index: Int) -> Any.Type {
        precondition(index >= 0 && index < count, "Index out of bounds")

        // Elements start at offset 24 (after kind, numElements, labels)
        // Each element is (Type: 8 bytes, Offset: 4 bytes, Padding: 4 bytes) = 16 bytes total
        let elementStart: UnsafeRawPointer = metadata.advanced(by: 24)
        let typePointer: Int = elementStart.advanced(by: index * 16).load(as: Int.self)

        return unsafeBitCast(typePointer, to: Any.Type.self)
    }

    /// Returns the byte offset of the tuple element at the specified index.
    ///
    /// - Parameter index: The zero-based index of the element
    /// - Returns: The byte offset from the start of the tuple value in memory
    ///
    /// This tells you where in memory each element is located within a tuple instance.
    /// For example, in `(Int, String, Bool)`, the Bool might be at offset 24 bytes.
    ///
    /// **Implementation Details:**
    /// - The offset is stored 8 bytes after the type pointer in each element descriptor
    /// - Offsets are stored as UInt32 (4 bytes) with 4 bytes of padding after
    /// - To access offset for element N: base + 24 + (N * 16) + 8
    func elementOffset(at index: Int) -> Int {
        precondition(index >= 0 && index < count, "Index out of bounds")

        // Each element descriptor is 16 bytes: Type (8 bytes) + Offset (4 bytes) + Padding (4 bytes)
        let elementStart: UnsafeRawPointer = metadata.advanced(by: 24)
        let offset: UInt32 = elementStart.advanced(by: index * 16 + 8).load(as: UInt32.self)

        return Int(offset)
    }
}

extension TupleType {
    var tupleDescriptor: TupleMetadata {
        let desc: TupleMetadata = metadata.load(as: TupleMetadata.self)
        return desc
    }
}
