//
//  File.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 10/03/2026.
//

import Foundation
#if canImport(AppKit)
import AppKit
#endif

func copyToClipboard(_ string: String) {
#if canImport(AppKit)
    let pasteboard: NSPasteboard = .general
    pasteboard.clearContents()
    pasteboard.setString(string, forType: .string)
#endif
}
