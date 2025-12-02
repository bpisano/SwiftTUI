//
//  TupleMetadata.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 27/11/2025.
//

import Foundation

struct TupleMetadata {
    let kind: Int
    let numElements: Int

    var fields: [TupleElement] {
        var result: [TupleElement] = []

        let start = withUnsafePointer(to: self) {
            UnsafeRawPointer($0).advanced(by: MemoryLayout<TupleMetadata>.size)
        }

        let ptr = start.bindMemory(to: TupleElement.self, capacity: numElements)

        for i in 0..<numElements {
            result.append(TupleElement(from: ptr + i))
        }
        return result
    }
}
