import Foundation
import Geometry

public final class Cursor {
    public private(set) var position: Point = .zero

    public func write(_ text: String) {
        print(text, terminator: "")
        fflush(stdout)
    }

    public func move(to point: Point) {
        let moveCommand: String = Terminal.make(command: .move(to: point))
        write(moveCommand)
        position = point
    }

    public func clearScreen() {
        let clearCommand: String = Terminal.make(command: .clearScreen)
        write(clearCommand)
        move(to: .zero)
    }
}
