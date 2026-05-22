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

    private let subscribeFunc: @Sendable (SubscriberPriority, @escaping @MainActor @Sendable (Event) -> Void) -> InputSubscription
    private let makeEvents: @Sendable @InputActor () -> AsyncStream<Keyboard.Event>

    public init(fileDescriptor: Int32 = STDIN_FILENO) {
        let decoder: KeyboardEventDecoder = .init()
        let center: KeyboardEventCenter = .shared

        self.subscribeFunc = { priority, handler in
            let id = center.subscribe(
                fileDescriptor: fileDescriptor,
                decoder: decoder,
                priority: priority,
                handler: handler
            )
            return InputSubscription {
                center.unsubscribe(id)
            }
        }
        self.makeEvents = {
            center.events(fileDescriptor: fileDescriptor, decoder: decoder)
        }
    }

    init(
        events: @escaping @Sendable @InputActor () -> AsyncStream<Keyboard.Event>,
        subscribe: @escaping @Sendable (SubscriberPriority, @escaping @MainActor @Sendable (Event) -> Void) -> InputSubscription
    ) {
        self.subscribeFunc = subscribe
        self.makeEvents = events
    }

    /// Backward-compatible: returns a broadcast stream of events. Subscribers
    /// receive events without ordering guarantees and cannot consume.
    public func events() -> AsyncStream<Keyboard.Event> {
        makeEvents()
    }

    /// `Input` conformance: subscribes with `.view` priority. Use the
    /// priority-aware overload for `.system` (focus router etc.).
    public func subscribe(
        handler: @escaping @MainActor @Sendable (Event) -> Void
    ) -> InputSubscription {
        subscribe(priority: .view, handler: handler)
    }

    /// Synchronous, priority-ordered subscription. Handlers registered with
    /// `.view` priority run first in registration order; then handlers with
    /// `.system` priority run, gated on `Event.isConsumed`.
    public func subscribe(
        priority: SubscriberPriority,
        handler: @escaping @MainActor @Sendable (Event) -> Void
    ) -> InputSubscription {
        subscribeFunc(priority, handler)
    }
}

extension Keyboard {
    public enum SubscriberPriority: Sendable {
        case view
        case system
    }
}

extension Keyboard {
    /// Reference-typed flag shared by every copy of an `Event` so a subscriber
    /// processed earlier can mark the event consumed and downstream
    /// `.system`-priority handlers (focus router, etc.) can skip it.
    public final class EventConsumeState: Sendable {
        private let flag: Mutex<Bool> = .init(false)

        public init() {}

        public var isConsumed: Bool {
            flag.withLock { $0 }
        }

        public func consume() {
            flag.withLock { $0 = true }
        }
    }

    public struct Event: Sendable {
        public enum Phase: Sendable, Hashable {
            case down
            case repeated
            case up
        }

        public let key: Key
        public let modifiers: Modifiers
        public let phase: Phase

        // Reference type so struct copies share the same flag across threads.
        private let consumeState: EventConsumeState

        public init(
            key: Key,
            modifiers: Modifiers = [],
            phase: Phase = .down
        ) {
            self.key = key
            self.modifiers = modifiers
            self.phase = phase
            self.consumeState = EventConsumeState()
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

        /// Marks this event as handled. `.system`-priority subscribers (focus
        /// router, etc.) skip events where `isConsumed == true`.
        public func consume() {
            consumeState.consume()
        }

        public var isConsumed: Bool {
            consumeState.isConsumed
        }

        func withModifiers(_ modifiers: Modifiers) -> Self {
            .init(
                key: key,
                modifiers: self.modifiers.union(modifiers),
                phase: phase
            )
        }
    }
}

extension Keyboard.Event: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(key)
        hasher.combine(modifiers)
        hasher.combine(phase)
    }

    public static func == (lhs: Keyboard.Event, rhs: Keyboard.Event) -> Bool {
        lhs.key == rhs.key && lhs.modifiers == rhs.modifiers && lhs.phase == rhs.phase
    }
}

extension Keyboard {
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

    private struct Handler {
        let id: UUID
        let handler: @MainActor @Sendable (Keyboard.Event) -> Void
    }

    private struct State {
        var viewHandlers: [Handler] = []
        var systemHandlers: [Handler] = []
        var legacyContinuations: [UUID: AsyncStream<Keyboard.Event>.Continuation] = [:]
        var readTask: Task<Void, Never>? = nil
    }

    private let state: Mutex<State> = .init(State())

    private init() {}

    func subscribe(
        fileDescriptor: Int32,
        decoder: KeyboardEventDecoder,
        priority: Keyboard.SubscriberPriority,
        handler: @escaping @MainActor @Sendable (Keyboard.Event) -> Void
    ) -> UUID {
        startIfNeeded(fileDescriptor: fileDescriptor, decoder: decoder)
        let id = UUID()
        state.withLock { s in
            let entry: Handler = .init(id: id, handler: handler)
            switch priority {
            case .view: s.viewHandlers.append(entry)
            case .system: s.systemHandlers.append(entry)
            }
        }
        return id
    }

    func unsubscribe(_ id: UUID) {
        state.withLock { s in
            s.viewHandlers.removeAll { $0.id == id }
            s.systemHandlers.removeAll { $0.id == id }
        }
    }

    func events(
        fileDescriptor: Int32,
        decoder: KeyboardEventDecoder
    ) -> AsyncStream<Keyboard.Event> {
        startIfNeeded(fileDescriptor: fileDescriptor, decoder: decoder)

        let id = UUID()
        return AsyncStream { continuation in
            state.withLock { $0.legacyContinuations[id] = continuation }
            continuation.onTermination = { [weak self] _ in
                _ = self?.state.withLock { $0.legacyContinuations.removeValue(forKey: id) }
            }
        }
    }

    private func startIfNeeded(
        fileDescriptor: Int32,
        decoder: KeyboardEventDecoder
    ) {
        state.withLock { s in
            guard s.readTask == nil else { return }
            s.readTask = Task.detached { [weak self] in
                var buffer: [UInt8] = Array(repeating: 0, count: 64)
                while !Task.isCancelled {
                    let count = read(fileDescriptor, &buffer, buffer.count)
                    guard count > 0 else { continue }
                    let bytes = Array(buffer.prefix(count))
                    for event in decoder.decode(bytes: bytes) {
                        await self?.dispatch(event)
                    }
                }
            }
        }
    }

    @MainActor
    private func dispatch(_ event: Keyboard.Event) {
        let snapshot: (view: [Handler], system: [Handler], legacy: [AsyncStream<Keyboard.Event>.Continuation]) = state.withLock { s in
            (s.viewHandlers, s.systemHandlers, Array(s.legacyContinuations.values))
        }

        for h in snapshot.view {
            h.handler(event)
        }
        for h in snapshot.system {
            if event.isConsumed { break }
            h.handler(event)
        }
        for continuation in snapshot.legacy {
            continuation.yield(event)
        }
    }
}
