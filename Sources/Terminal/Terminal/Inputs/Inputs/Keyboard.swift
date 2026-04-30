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

private final class KeyboardEventCenter: @unchecked Sendable {
    static let shared = KeyboardEventCenter()

    private let lock = NSLock()
    private var continuations: [UUID: AsyncStream<Keyboard.Event>.Continuation] = [:]
    private var task: Task<Void, Never>?

    private init() {}

    func events(
        fileDescriptor: Int32,
        decoder: KeyboardEventDecoder
    ) -> AsyncStream<Keyboard.Event> {
        startIfNeeded(fileDescriptor: fileDescriptor, decoder: decoder)

        let id = UUID()
        return AsyncStream { continuation in
            insert(continuation, id: id)
            continuation.onTermination = { [weak self] _ in
                self?.remove(id: id)
            }
        }
    }

    private func startIfNeeded(
        fileDescriptor: Int32,
        decoder: KeyboardEventDecoder
    ) {
        lock.lock()
        defer { lock.unlock() }

        guard task == nil else { return }

        task = Task.detached { [weak self] in
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

    private func insert(
        _ continuation: AsyncStream<Keyboard.Event>.Continuation,
        id: UUID
    ) {
        lock.lock()
        continuations[id] = continuation
        lock.unlock()
    }

    private func remove(id: UUID) {
        lock.lock()
        continuations.removeValue(forKey: id)
        lock.unlock()
    }

    private func yield(_ event: Keyboard.Event) {
        lock.lock()
        let currentContinuations = Array(continuations.values)
        lock.unlock()

        for continuation in currentContinuations {
            continuation.yield(event)
        }
    }
}
