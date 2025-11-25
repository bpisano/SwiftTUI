import Geometry

public struct MoveCursor: Command {
    private let point: Point

    public init(to point: Point) {
        self.point = point
    }

    public func makeCommand() -> String {
        return "\u{1B}[\(Int(point.y));\(Int(point.x))H"
    }
}

extension Command where Self == MoveCursor {
    public static func move(to point: Point) -> MoveCursor {
        return MoveCursor(to: point)
    }
}
