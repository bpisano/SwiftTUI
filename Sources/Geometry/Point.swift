public struct Point: Hashable, Equatable, Codable, Sendable {
    public static let zero = Point(x: 0, y: 0)

    public var x: GeometryUnit
    public var y: GeometryUnit

    public init(x: GeometryUnit, y: GeometryUnit) {
        self.x = x
        self.y = y
    }

    public init(x: Int, y: Int) {
        self.x = GeometryUnit(x)
        self.y = GeometryUnit(y)
    }

    public static func + (lhs: Point, rhs: Point) -> Point {
        return Point(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    public static func - (lhs: Point, rhs: Point) -> Point {
        return Point(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }

    public static func * (lhs: Point, rhs: Double) -> Point {
        return Point(x: lhs.x * rhs, y: lhs.y * rhs)
    }

    public static func / (lhs: Point, rhs: Double) -> Point {
        return Point(x: lhs.x / rhs, y: lhs.y / rhs)
    }

    public func distance(to point: Point) -> Double {
        let dx: GeometryUnit = point.x - x
        let dy: GeometryUnit = point.y - y
        return (dx * dx + dy * dy).squareRoot()
    }
}

extension Point: CustomStringConvertible {
    public var description: String {
        "(\(x), \(y))"
    }
}
