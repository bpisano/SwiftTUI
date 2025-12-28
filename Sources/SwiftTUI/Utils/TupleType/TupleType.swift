//
//  TupleType.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 27/11/2025.
//

import Foundation

struct TupleType {
    private let metadata: UnsafeRawPointer

    init(_ type: Any.Type) {
        self.metadata = unsafeBitCast(type, to: UnsafeRawPointer.self)
        print("Metadata pointer:", metadata)

        // Debug: print more words
        for i in 0..<10 {
            let value = metadata.advanced(by: i * 8).load(as: Int.self)
            print("Word \(i) (offset \(i*8)):", String(format: "0x%lx", value))
        }
    }

    var count: Int {
        metadata.advanced(by: MemoryLayout<Int>.size).load(as: Int.self)
    }

    func type(at index: Int) -> Any.Type {
        precondition(index >= 0 && index < count, "Index out of bounds")

        // Elements start at offset 24 (after kind, numElements, labels)
        // Each element is (Type: 8 bytes, Offset: 8 bytes) = 16 bytes total
        let elementStart = metadata.advanced(by: 24)
        let typePointer = elementStart.advanced(by: index * 16).load(as: Int.self)

        return unsafeBitCast(typePointer, to: Any.Type.self)
    }

    func elementOffset(at index: Int) -> Int {
        precondition(index >= 0 && index < count, "Index out of bounds")

        // Each element is (Type: 8 bytes, Offset: 8 bytes)
        let elementStart = metadata.advanced(by: 24)
        let offset = elementStart.advanced(by: index * 16 + 8).load(as: UInt32.self)

        return Int(offset)
    }
}

private extension TupleType {
    var tupleDescriptor: TupleMetadata {
        let desc = metadata.load(as: TupleMetadata.self)
        print("Loaded TupleMetadata - kind:", desc.kind, "numElements:", desc.numElements)
        return desc
    }
}

private struct TupleMetadata {
    let kind: Int
    let numElements: Int

    func elementType(at index: Int) -> Any.Type {
        print("  Getting element type at index \(index)")

        let baseAddress = withUnsafePointer(to: self) { ptr in
            let base = UnsafeRawPointer(ptr)
            print("  Base address:", base)
            print("  After header:", base.advanced(by: MemoryLayout<TupleMetadata>.size))
            return base
                .advanced(by: MemoryLayout<TupleMetadata>.size)
                .advanced(by: MemoryLayout<Int>.size)
        }
        print("  Types array starts at:", baseAddress)

        let typeAddress = baseAddress.advanced(by: index * MemoryLayout<Int>.size)
        print("  Reading type from:", typeAddress)

        let typePointer = typeAddress.load(as: Int.self)
        print("  Type pointer value:", String(format: "0x%lx", typePointer))

        let type = unsafeBitCast(typePointer, to: Any.Type.self)
        print("  Type:", type)
        return type
    }

    func elementOffset(at index: Int) -> Int {
        print("  Getting element offset at index \(index)")

        let baseAddress = withUnsafePointer(to: self) { ptr in
            UnsafeRawPointer(ptr)
                .advanced(by: MemoryLayout<TupleMetadata>.size)
                .advanced(by: MemoryLayout<Int>.size)
                .advanced(by: numElements * MemoryLayout<Int>.size)
        }
        print("  Offsets array starts at:", baseAddress)

        let offsetAddress = baseAddress.advanced(by: index * MemoryLayout<UInt32>.size)
        print("  Reading offset from:", offsetAddress)

        let offset = offsetAddress.load(as: UInt32.self)
        print("  Offset value:", offset)

        return Int(offset)
    }
}

//struct TupleType {
//    private let metadata: UnsafeRawPointer
//
//    init(_ type: Any.Type) {
//        self.metadata = unsafeBitCast(type, to: UnsafeRawPointer.self)
//    }
//
//    /// Number of tuple elements
//    var count: Int {
//        tupleDescriptor.numElements
//    }
//
//    /// Returns the type of an element at index
//    func type(at index: Int) -> Any.Type {
//        let descriptor: TupleMetadata = tupleDescriptor
//        let field: TupleElement = descriptor.fields[index]
//        return field.type
//    }
//}
//
//private extension TupleType {
//    /// Interpret metadata as Tuple Metadata
//    var tupleDescriptor: TupleMetadata {
//        metadata.assumingMemoryBound(to: TupleMetadata.self).pointee
//    }
//}
