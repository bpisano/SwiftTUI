//
//  StringExtensions.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 10/03/2026.
//

import Foundation

extension String {
    /// Slices the string into chunks of a specified size.
    /// - Parameter size: The size of each chunk. Must be greater than 0.
    /// - Returns: An array of string chunks. If the size is greater than the string length, returns an array with the original string as the only element. If the size is less than or equal to 0, returns an empty array.
    func slice(_ size: Int) -> [String] {
        guard size > 0 else { return [] }

        var result: [String] = []
        var startIndex: String.Index = startIndex

        while startIndex < endIndex {
            let endIndex: String.Index = index(
                startIndex,
                offsetBy: size,
                limitedBy: endIndex
            ) ?? endIndex
            let chunk: String = .init(self[startIndex..<endIndex])
            result.append(chunk)
            startIndex = endIndex
        }

        return result
    }
}
