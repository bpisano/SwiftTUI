//
//  RenderState.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 25/03/2026.
//

import Foundation

@MainActor
final class RenderState {
    var needsRender: Bool = true

    func setNeedsRender() {
        needsRender = true
    }

    func clearNeedsRender() {
        needsRender = false
    }
}
