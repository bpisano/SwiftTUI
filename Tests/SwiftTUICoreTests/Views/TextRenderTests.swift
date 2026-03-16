//
//  TextRenderTests.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 16/03/2026.
//

import Foundation
import Testing
import Geometry
@testable import SwiftTUICore

@Suite("Text Rendering")
struct TextRenderTests {
    @Test
    func `Simple Text`() async throws {
        let renderer = UnitTestRenderer(in: Size(width: 10, height: 3)) {
            Text("Hello")
        }
        renderer.emptyChar = "."
        
        let expected = """
        Hello.....
        ..........
        ..........
        """
        
        #expect(renderer.render() == expected)
    }
    
    @Test
    func `Multiple Lines`() async throws {
        let renderer = UnitTestRenderer(in: Size(width: 10, height: 10)) {
            VStack {
                Text("Alice")
                Text("Bob")
            }
        }
        renderer.emptyChar = "."
        
        let output = renderer.render()
        
        // Verify Alice appears
        #expect(output.contains("Alice"))
        // Verify Bob appears
        #expect(output.contains("Bob"))
    }
}
