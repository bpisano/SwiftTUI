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
    }

    /// Number of tuple elements
    var count: Int {
        tupleDescriptor.numElements
    }

    /// Returns the type of an element at index
    func type(at index: Int) -> Any.Type {
        let descriptor: TupleMetadata = tupleDescriptor
        let field: TupleElement = descriptor.fields[index]
        return field.type
    }
}

private extension TupleType {
    /// Interpret metadata as Tuple Metadata
    var tupleDescriptor: TupleMetadata {
        metadata.assumingMemoryBound(to: TupleMetadata.self).pointee
    }
}
