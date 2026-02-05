//
//  Keyboard.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 29/01/2026.
//

import Foundation

public struct Keyboard: Input, Sendable {
    public enum Event: Sendable {
        case keyPress(Key)
        case keyRelease(Key)
    }

    public static let current: Keyboard = .init()

    private init() {}

    public func events() -> AsyncStream<Keyboard.Event> {
        AsyncStream { continuation in
            let task: Task<Void, Never> = .init {
                var buffer: [UInt8] = Array(repeating: 0, count: 8)
                while !Task.isCancelled {
                    let count: Int = read(STDIN_FILENO, &buffer, buffer.count)
                    guard count >= 0 else { continue }
                    guard let event = decode(buffer: buffer, count: count) else { continue }
                    continuation.yield(event)
                }
            }

            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }

    @InputActor
    private func decode(buffer: [UInt8], count: Int) -> Keyboard.Event? {
        switch buffer[0] {
        case 13:
            return .keyPress(.enter)
        case 27:
            return .keyPress(.escape)
        case 32:
            return .keyPress(.space)
        case 127:
            return .keyPress(.delete)
        default:
            if buffer[0] >= 32 && buffer[0] <= 126 {
                let char: String = String(UnicodeScalar(buffer[0]))
                return .keyPress(.character(char))
            }
            return nil
        }
    }
}

extension Keyboard {
    public enum Key: Sendable {
        case character(String)
        case command
        case shift
        case option
        case control
        case space
        case delete
        case enter
        case escape
        case arrowUp
        case arrowDown
        case arrowLeft
        case arrowRight
    }
}

extension Input where Self == Keyboard {
    public static var keyboard: Keyboard {
        .current
    }
}
