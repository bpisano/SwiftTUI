import Geometry

public struct MoveCursor: Command {
    private let point: Point

    public init(to point: Point) {
        self.point = point
    }

    public func makeCommand() -> String {
        "\u{1B}[\(Int(point.y) + 1);\(Int(point.x) + 1)H"
    }
}

extension Command where Self == MoveCursor {
    public static func move(to point: Point) -> MoveCursor {
        return MoveCursor(to: point)
    }
}
