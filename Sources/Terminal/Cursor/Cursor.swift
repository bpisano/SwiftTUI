import Foundation
import Geometry

public final class Cursor {
    public let parent: Cursor?
    public private(set) var position: Point = .zero
    public var absolutePosition: Point {
        absolutePosition(for: position)
    }

    package init() {
        self.parent = nil
    }

    package init(from cursor: Cursor) {
        self.parent = cursor
    }

    public func write(_ text: String) {
        writeBuffered(text)
        flush()
    }

    public func writeBuffered(_ text: String) {
        print(text, terminator: "")
    }

    public func flush() {
        fflush(stdout)
    }

    public func move(to point: Point) {
        let targetPosition: Point = absolutePosition(for: point + Point(x: 1, y: 1))
        let moveCommand: String = Terminal.make(command: .move(to: targetPosition))
        write(moveCommand)
        position = point
    }

    public func clearScreen() {
        let clearCommand: String = Terminal.make(command: .clearScreen)
        write(clearCommand)
        move(to: .zero)
    }

    private func absolutePosition(for point: Point) -> Point {
        if let parent {
            parent.absolutePosition + point
        } else {
            point
        }
    }
}
