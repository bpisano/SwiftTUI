//
//  File.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 10/03/2026.
//

import Foundation
import AttributeGraph
#if canImport(AppKit)
import AppKit
#endif

#if canImport(AppKit)
extension Graph {
    public func copyToClipboard() {
        let pasteboard: NSPasteboard = .general
        pasteboard.clearContents()
        pasteboard.setString(digraph, forType: .string)
    }
}
#endif
