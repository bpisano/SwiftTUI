//
//  KeyboardEventDecoder.swift
//  SwiftTUI
//
//  Created on 27/04/2026.
//

import Foundation

public struct KeyboardEventDecoder: Sendable {
    public init() {}

    public func decode(bytes: [UInt8]) -> [Keyboard.Event] {
        var events: [Keyboard.Event] = []
        var index = bytes.startIndex

        while index < bytes.endIndex {
            let remaining = bytes[index..<bytes.endIndex]
            if let parsed = parseEvent(from: remaining) {
                events.append(parsed.event)
                index = bytes.index(index, offsetBy: parsed.length)
            } else {
                index = bytes.index(after: index)
            }
        }

        return events
    }
}

private extension KeyboardEventDecoder {
    typealias Event = Keyboard.Event
    typealias Key = Keyboard.Key
    typealias Modifiers = Keyboard.Modifiers

    static func phaseFromKittyEventType(_ eventType: Int) -> Event.Phase {
        switch eventType {
        case 2:
            return .repeated
        case 3:
            return .up
        default:
            return .down
        }
    }

    static func isCSIFinalByte(_ byte: UInt8) -> Bool {
        byte >= 64 && byte <= 126
    }

    static var shiftedPunctuation: Set<UInt8> {
        [
            33, 34, 35, 36, 37, 38, 40, 41, 42, 43,
            58, 60, 62, 63, 64, 94, 95, 123, 124, 125, 126
        ]
    }

    func parseEvent(
        from bytes: ArraySlice<UInt8>
    ) -> (event: Event, length: Int)? {
        guard let first = bytes.first else { return nil }

        if first == 27 {
            return parseEscapeSequence(from: bytes)
        }

        return parseSingleByte(first).map { ($0, 1) }
    }

    func parseEscapeSequence(
        from bytes: ArraySlice<UInt8>
    ) -> (event: Event, length: Int)? {
        guard bytes.count > 1 else {
            return (.keyPress(.escape), 1)
        }

        let secondIndex: Int = bytes.index(after: bytes.startIndex)
        let second: UInt8 = bytes[secondIndex]

        switch second {
        case 91:
            return parseCSISequence(from: bytes)
        case 79:
            return parseSS3Sequence(from: bytes)
        default:
            let nested = bytes[secondIndex..<bytes.endIndex]
            guard let parsed = parseEvent(from: nested) else {
                return (.keyPress(.escape), 1)
            }
            return (
                parsed.event.withModifiers(.option),
                parsed.length + 1
            )
        }
    }

    func parseSingleByte(_ byte: UInt8) -> Event? {
        switch byte {
        case 9:
            return .keyPress(.tab)
        case 10, 13:
            return .keyPress(.enter)
        case 27:
            return .keyPress(.escape)
        case 32:
            return .keyPress(.space)
        case 127:
            return .keyPress(.delete)
        case 1...8, 11...12, 14...26:
            let scalar = UnicodeScalar(Int(byte + 96))
            return scalar.map {
                .keyPress(
                    .character(String($0)),
                    modifiers: .control
                )
            }
        case 28:
            return .keyPress(.character("\\"), modifiers: .control)
        case 29:
            return .keyPress(.character("]"), modifiers: .control)
        case 30:
            return .keyPress(.character("^"), modifiers: .control)
        case 31:
            return .keyPress(.character("_"), modifiers: .control)
        case 33...126:
            return printableEvent(for: byte, phase: .down)
        default:
            return nil
        }
    }

    func printableEvent(
        for byte: UInt8,
        phase: Event.Phase,
        modifiers: Modifiers = []
    ) -> Event? {
        var modifiers: Modifiers = modifiers

        if byte >= 65 && byte <= 90 {
            modifiers.insert(.shift)
            let scalar: UnicodeScalar? = .init(Int(byte + 32))
            return scalar.map {
                Event(
                    key: .character(String($0)),
                    modifiers: modifiers,
                    phase: phase
                )
            }
        }

        if Self.shiftedPunctuation.contains(byte) {
            modifiers.insert(.shift)
        }

        return UnicodeScalar(Int(byte)).map {
            Event(
                key: .character(String($0)),
                modifiers: modifiers,
                phase: phase
            )
        }
    }

    func parseCSISequence(
        from bytes: ArraySlice<UInt8>
    ) -> (event: Event, length: Int)? {
        guard bytes.count >= 3 else { return nil }

        let parametersStart: Int = bytes.index(bytes.startIndex, offsetBy: 2)
        guard let finalIndex = bytes[parametersStart..<bytes.endIndex].firstIndex(where: Self.isCSIFinalByte) else {
            return nil
        }

        let finalByte: UInt8 = bytes[finalIndex]
        let parametersBytes = bytes[parametersStart..<finalIndex]
        let parameters = String(decoding: parametersBytes, as: UTF8.self)

        guard let event = eventForCSI(parameters: parameters, finalByte: finalByte) else {
            return nil
        }

        return (
            event,
            bytes.distance(from: bytes.startIndex, to: bytes.index(after: finalIndex))
        )
    }

    func parseSS3Sequence(
        from bytes: ArraySlice<UInt8>
    ) -> (event: Event, length: Int)? {
        guard bytes.count >= 3 else { return nil }
        let finalIndex = bytes.index(bytes.startIndex, offsetBy: 2)

        let key: Key? = switch bytes[finalIndex] {
        case 65: .arrowUp
        case 66: .arrowDown
        case 67: .arrowRight
        case 68: .arrowLeft
        case 70: .end
        case 72: .home
        default: nil
        }

        return key.map { (.keyPress($0), 3) }
    }

    func eventForCSI(
        parameters: String,
        finalByte: UInt8
    ) -> Event? {
        let fields = parameterFields(parameters)
        let modifiers = fields.count > 1
            ? modifiersFromCSIParameter(integerComponent(fields[1]))
            : []
        let phase = phaseFromCSIUFields(fields)

        switch finalByte {
        case 65:
            return Event(key: .arrowUp, modifiers: modifiers, phase: phase)
        case 66:
            return Event(key: .arrowDown, modifiers: modifiers, phase: phase)
        case 67:
            return Event(key: .arrowRight, modifiers: modifiers, phase: phase)
        case 68:
            return Event(key: .arrowLeft, modifiers: modifiers, phase: phase)
        case 70:
            return Event(key: .end, modifiers: modifiers, phase: phase)
        case 72:
            return Event(key: .home, modifiers: modifiers, phase: phase)
        case 90:
            return Event(key: .tab, modifiers: [.shift], phase: phase)
        case 117:
            return eventForCSIU(parameters: parameters)
        case 126:
            return eventForTilde(parameters: parameters)
        default:
            return nil
        }
    }

    func eventForTilde(parameters: String) -> Event? {
        let fields = parameterFields(parameters)
        guard let code = integerComponent(fields.first) else { return nil }
        let modifiers = fields.count > 1
            ? modifiersFromCSIParameter(integerComponent(fields[1]))
            : []

        let key: Key? = switch code {
        case 1, 7:
            .home
        case 3:
            .delete
        case 4, 8:
            .end
        case 5:
            .pageUp
        case 6:
            .pageDown
        default:
            nil
        }

        return key.map {
            .keyPress($0, modifiers: modifiers)
        }
    }

    func eventForCSIU(parameters: String) -> Event? {
        let fields = parameterFields(parameters)
        guard let keyCode = integerComponent(fields.first) else { return nil }

        let modifiers = fields.count > 1
            ? modifiersFromCSIParameter(integerComponent(fields[1]))
            : []
        let phase = phaseFromCSIUFields(fields)

        return eventForKeyCode(
            keyCode,
            modifiers: modifiers,
            phase: phase
        )
    }

    func eventForKeyCode(
        _ keyCode: Int,
        modifiers: Modifiers,
        phase: Event.Phase
    ) -> Event? {
        switch keyCode {
        case 9:
            return Event(key: .tab, modifiers: modifiers, phase: phase)
        case 10, 13:
            return Event(key: .enter, modifiers: modifiers, phase: phase)
        case 27:
            return Event(key: .escape, modifiers: modifiers, phase: phase)
        case 32:
            return Event(key: .space, modifiers: modifiers, phase: phase)
        case 127:
            return Event(key: .delete, modifiers: modifiers, phase: phase)
        case 33...126:
            return printableEvent(
                for: UInt8(keyCode),
                phase: phase,
                modifiers: modifiers
            )
        default:
            return UnicodeScalar(keyCode).map {
                Event(
                    key: .character(String($0)),
                    modifiers: modifiers,
                    phase: phase
                )
            }
        }
    }

    func phaseFromCSIUFields(_ fields: [String]) -> Event.Phase {
        if fields.count > 1 {
            let components = fields[1].split(
                separator: ":",
                omittingEmptySubsequences: false
            )
            if components.count > 1,
               let eventType = Int(components[1]) {
                return Self.phaseFromKittyEventType(eventType)
            }
        }

        if fields.count > 2,
           let eventType = integerComponent(fields[2]) {
            return Self.phaseFromKittyEventType(eventType)
        }

        return .down
    }

    func parameterFields(_ parameters: String) -> [String] {
        parameters
            .split(separator: ";", omittingEmptySubsequences: false)
            .map(String.init)
    }

    func integerComponent(_ field: String?) -> Int? {
        guard let field else { return nil }
        let component = field
            .split(separator: ":", omittingEmptySubsequences: false)
            .first
        return component.flatMap { Int($0) }
    }

    func modifiersFromCSIParameters(_ parameters: String) -> Modifiers {
        let fields = parameterFields(parameters)
        guard fields.count > 1 else { return [] }
        return modifiersFromCSIParameter(integerComponent(fields[1]))
    }

    func modifiersFromCSIParameter(_ parameter: Int?) -> Modifiers {
        guard let parameter else { return [] }

        let encoded = max(0, parameter - 1)
        var modifiers: Modifiers = []

        if encoded & 1 != 0 {
            modifiers.insert(.shift)
        }

        if encoded & 2 != 0 {
            modifiers.insert(.option)
        }

        if encoded & 4 != 0 {
            modifiers.insert(.control)
        }

        if encoded & 8 != 0 {
            modifiers.insert(.command)
        }

        return modifiers
    }
}
