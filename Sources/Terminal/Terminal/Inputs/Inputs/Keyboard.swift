//
//  Keyboard.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 29/01/2026.
//

import Foundation
import Synchronization

#if os(macOS)
    import Darwin
#elseif os(Linux)
    import Glibc
#endif

public struct Keyboard: Input, Sendable {
    public static let current: Keyboard = .init()

    private let makeEvents: @Sendable @InputActor () -> AsyncStream<Keyboard.Event>

    public init(fileDescriptor: Int32 = STDIN_FILENO) {
        let decoder: KeyboardEventDecoder = .init()

        self.makeEvents = {
            KeyboardEventCenter.shared.events(
                fileDescriptor: fileDescriptor,
                decoder: decoder
            )
        }
    }

    init(events: @escaping @Sendable @InputActor () -> AsyncStream<Keyboard.Event>) {
        self.makeEvents = events
    }

    public func events() -> AsyncStream<Keyboard.Event> {
        makeEvents()
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

extension Input where Self == Keyboard {
    public static var keyboard: Keyboard {
        .current
    }
}

private final class KeyboardEventCenter: Sendable {
    static let shared: KeyboardEventCenter = .init()

    private struct State {
        var continuations: [UUID: AsyncStream<Keyboard.Event>.Continuation] = [:]
        var task: Task<Void, Never>? = nil
    }

    private let state = Mutex<State>(State())

    private init() {}

    func events(
        fileDescriptor: Int32,
        decoder: KeyboardEventDecoder
    ) -> AsyncStream<Keyboard.Event> {
        startIfNeeded(fileDescriptor: fileDescriptor, decoder: decoder)

        let id = UUID()
        return AsyncStream { continuation in
            state.withLock { $0.continuations[id] = continuation }
            continuation.onTermination = { [weak self] _ in
                _ = self?.state.withLock { $0.continuations.removeValue(forKey: id) }
            }
        }
    }

    private func startIfNeeded(
        fileDescriptor: Int32,
        decoder: KeyboardEventDecoder
    ) {
        state.withLock { s in
            guard s.task == nil else { return }
            s.task = Task.detached { [weak self] in
                var buffer: [UInt8] = Array(repeating: 0, count: 64)
                while !Task.isCancelled {
                    let count = read(fileDescriptor, &buffer, buffer.count)
                    guard count > 0 else { continue }

                    let bytes = Array(buffer.prefix(count))
                    for event in decoder.decode(bytes: bytes) {
                        self?.yield(event)
                    }
                }
            }
        }
    }

    private func yield(_ event: Keyboard.Event) {
        let snapshot = state.withLock { Array($0.continuations.values) }
        for continuation in snapshot {
            continuation.yield(event)
        }
    }
}
