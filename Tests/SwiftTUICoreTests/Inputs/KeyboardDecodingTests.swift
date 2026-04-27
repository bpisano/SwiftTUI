//
//  KeyboardDecodingTests.swift
//  SwiftTUI
//
//  Created on 25/04/2026.
//

import Testing

@testable import Terminal

@Suite("Keyboard decoding")
struct KeyboardDecodingTests {
    @Test
    func `decodes multiple printable keys from one read`() {
        let events = Keyboard.decode(bytes: Array("ab".utf8))

        #expect(events == [
            .keyPress(.character("a")),
            .keyPress(.character("b"))
        ])
    }

    @Test
    func `decodes uppercase letters as shifted lowercase keys`() {
        let events = Keyboard.decode(bytes: Array("A".utf8))

        #expect(events == [
            .keyPress(.character("a"), modifiers: .shift)
        ])
    }

    @Test
    func `decodes option modified printable keys`() {
        let events = Keyboard.decode(bytes: [27, 97])

        #expect(events == [
            .keyPress(.character("a"), modifiers: .option)
        ])
    }

    @Test
    func `decodes CSI arrow key modifiers`() {
        let events = Keyboard.decode(bytes: Array("\u{1B}[1;6A".utf8))

        #expect(events == [
            .keyPress(.arrowUp, modifiers: [.shift, .control])
        ])
    }

    @Test
    func `decodes CSI-u key release events`() {
        let events = Keyboard.decode(bytes: Array("\u{1B}[97;5:3u".utf8))

        #expect(events == [
            .keyUp(.character("a"), modifiers: .control)
        ])
    }
}
