//
//  TupleMetadata.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 27/11/2025.
//

import Foundation

//struct TupleMetadata {
//    let kind: Int
//    let numElements: Int
//
//    var fields: [TupleElement] {
//        var result: [TupleElement] = []
//
//        // The fields start right after the TupleMetadata header
//        let start = withUnsafePointer(to: self) {
//            UnsafeRawPointer($0).advanced(by: MemoryLayout<TupleMetadata>.size)
//        }
//
//        // Each element is stored as: (Type, Offset)
//        // Type is a pointer (8 bytes on 64-bit), Offset is an Int (8 bytes)
//        let elementSize = MemoryLayout<Int>.size * 2 // Type pointer + offset
//
//        for i in 0..<numElements {
//            let elementPtr = start.advanced(by: i * elementSize)
//
//            // Read type (first 8 bytes)
//            let typePtr = elementPtr.load(as: Int.self)
//            let type = unsafeBitCast(typePtr, to: Any.Type.self)
//
//            // Read offset (next 8 bytes)
//            let offset = elementPtr.advanced(by: MemoryLayout<Int>.size).load(as: Int.self)
//
//            result.append(TupleElement(type: type, offset: offset))
//        }
//        return result
//    }
//}
