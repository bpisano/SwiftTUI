//
//  Keyboard.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 29/01/2026.
//

import Foundation

#if os(macOS)
    import Darwin
#elseif os(Linux)
    import Glibc
#endif

public struct Keyboard: Input, Sendable {
    public static let current: Keyboard = .init()

    private let makeEvents: @Sendable @InputActor () -> AsyncStream<Keyboard.Event>

    public init(fileDescriptor: Int32 = STDIN_FILENO) {
        self.makeEvents = {
            AsyncStream { continuation in
                let task: Task<Void, Never> = .init {
                    var buffer: [UInt8] = Array(repeating: 0, count: 64)
                    while !Task.isCancelled {
                        let count: Int = read(fileDescriptor, &buffer, buffer.count)
                        guard count > 0 else { continue }

                        let bytes = Array(buffer.prefix(count))
                        for event in Self.decode(bytes: bytes) {
                            continuation.yield(event)
                        }
                    }
                }

                continuation.onTermination = { _ in
                    task.cancel()
                }
            }
        }
    }

    init(events: @escaping @Sendable @InputActor () -> AsyncStream<Keyboard.Event>) {
        self.makeEvents = events
    }

    public func events() -> AsyncStream<Keyboard.Event> {
        makeEvents()
    }

    static func decode(bytes: [UInt8]) -> [Keyboard.Event] {
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

extension Keyboard {
    public struct Event: Sendable, Hashable {
        public enum Phase: Sendable, Hashable {
            case down
            case repeated
            case up
        }

        public let key: Key
        public let modifiers: Modifiers
        public let phase: Phase

        public init(
            key: Key,
            modifiers: Modifiers = [],
            phase: Phase = .down
        ) {
            self.key = key
            self.modifiers = modifiers
            self.phase = phase
        }

        public static func keyPress(
            _ key: Key,
            modifiers: Modifiers = []
        ) -> Self {
            .init(key: key, modifiers: modifiers, phase: .down)
        }

        public static func keyDown(
            _ key: Key,
            modifiers: Modifiers = []
        ) -> Self {
            .init(key: key, modifiers: modifiers, phase: .down)
        }

        public static func keyRepeat(
            _ key: Key,
            modifiers: Modifiers = []
        ) -> Self {
            .init(key: key, modifiers: modifiers, phase: .repeated)
        }

        public static func keyRelease(
            _ key: Key,
            modifiers: Modifiers = []
        ) -> Self {
            .init(key: key, modifiers: modifiers, phase: .up)
        }

        public static func keyUp(
            _ key: Key,
            modifiers: Modifiers = []
        ) -> Self {
            .init(key: key, modifiers: modifiers, phase: .up)
        }

        public var isPressed: Bool {
            phase == .down || phase == .repeated
        }

        func withModifiers(_ modifiers: Modifiers) -> Self {
            .init(
                key: key,
                modifiers: self.modifiers.union(modifiers),
                phase: phase
            )
        }
    }

    public struct Modifiers: OptionSet, Sendable, Hashable {
        public let rawValue: UInt8

        public init(rawValue: UInt8) {
            self.rawValue = rawValue
        }

        public static let shift: Self = .init(rawValue: 1 << 0)
        public static let option: Self = .init(rawValue: 1 << 1)
        public static let alt: Self = .option
        public static let control: Self = .init(rawValue: 1 << 2)
        public static let command: Self = .init(rawValue: 1 << 3)
    }

    public enum Key: Sendable, Hashable {
        case character(String)

        @available(*, deprecated, message: "Use Keyboard.Modifiers.command instead.")
        case command

        @available(*, deprecated, message: "Use Keyboard.Modifiers.shift instead.")
        case shift

        @available(*, deprecated, message: "Use Keyboard.Modifiers.option instead.")
        case option

        @available(*, deprecated, message: "Use Keyboard.Modifiers.control instead.")
        case control

        case tab
        case space
        case delete
        case enter
        case escape
        case arrowUp
        case arrowDown
        case arrowLeft
        case arrowRight
        case home
        case end
        case pageUp
        case pageDown
    }
}

private extension Keyboard {
    static func parseEvent(
        from bytes: ArraySlice<UInt8>
    ) -> (event: Event, length: Int)? {
        guard let first = bytes.first else { return nil }

        if first == 27 {
            return parseEscapeSequence(from: bytes)
        }

        return parseSingleByte(first).map { ($0, 1) }
    }

    static func parseEscapeSequence(
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

    static func parseSingleByte(_ byte: UInt8) -> Event? {
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

    static func printableEvent(
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

        if shiftedPunctuation.contains(byte) {
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

    static func parseCSISequence(
        from bytes: ArraySlice<UInt8>
    ) -> (event: Event, length: Int)? {
        guard bytes.count >= 3 else { return nil }

        let parametersStart: Int = bytes.index(bytes.startIndex, offsetBy: 2)
        guard let finalIndex = bytes[parametersStart..<bytes.endIndex].firstIndex(where: isCSIFinalByte) else {
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

    static func parseSS3Sequence(
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

    static func eventForCSI(
        parameters: String,
        finalByte: UInt8
    ) -> Event? {
        let modifiers = modifiersFromCSIParameters(parameters)

        switch finalByte {
        case 65:
            return .keyPress(.arrowUp, modifiers: modifiers)
        case 66:
            return .keyPress(.arrowDown, modifiers: modifiers)
        case 67:
            return .keyPress(.arrowRight, modifiers: modifiers)
        case 68:
            return .keyPress(.arrowLeft, modifiers: modifiers)
        case 70:
            return .keyPress(.end, modifiers: modifiers)
        case 72:
            return .keyPress(.home, modifiers: modifiers)
        case 90:
            return .keyPress(.tab, modifiers: [.shift])
        case 117:
            return eventForCSIU(parameters: parameters)
        case 126:
            return eventForTilde(parameters: parameters)
        default:
            return nil
        }
    }

    static func eventForTilde(parameters: String) -> Event? {
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

    static func eventForCSIU(parameters: String) -> Event? {
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

    static func eventForKeyCode(
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

    static func phaseFromCSIUFields(_ fields: [String]) -> Event.Phase {
        if fields.count > 1 {
            let components = fields[1].split(
                separator: ":",
                omittingEmptySubsequences: false
            )
            if components.count > 1,
               let eventType = Int(components[1]) {
                return phaseFromKittyEventType(eventType)
            }
        }

        if fields.count > 2,
           let eventType = integerComponent(fields[2]) {
            return phaseFromKittyEventType(eventType)
        }

        return .down
    }

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

    static func parameterFields(_ parameters: String) -> [String] {
        parameters
            .split(separator: ";", omittingEmptySubsequences: false)
            .map(String.init)
    }

    static func integerComponent(_ field: String?) -> Int? {
        guard let field else { return nil }
        let component = field
            .split(separator: ":", omittingEmptySubsequences: false)
            .first
        return component.flatMap { Int($0) }
    }

    static func modifiersFromCSIParameters(_ parameters: String) -> Modifiers {
        let fields = parameterFields(parameters)
        guard fields.count > 1 else { return [] }
        return modifiersFromCSIParameter(integerComponent(fields[1]))
    }

    static func modifiersFromCSIParameter(_ parameter: Int?) -> Modifiers {
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

    static func isCSIFinalByte(_ byte: UInt8) -> Bool {
        byte >= 64 && byte <= 126
    }

    static var shiftedPunctuation: Set<UInt8> {
        [
            33, 34, 35, 36, 37, 38, 40, 41, 42, 43,
            58, 60, 62, 63, 64, 94, 95, 123, 124, 125, 126
        ]
    }
}

extension Input where Self == Keyboard {
    public static var keyboard: Keyboard {
        .current
    }
}
