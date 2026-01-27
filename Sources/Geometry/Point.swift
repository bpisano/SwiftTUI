public struct Point: Hashable, Equatable, Codable, Sendable {
    public static let zero = Point(x: 0, y: 0)

    public var x: Double
    public var y: Double

    public init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }

    public init(x: Int, y: Int) {
        self.x = Double(x)
        self.y = Double(y)
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
        let dx: Double = point.x - x
        let dy: Double = point.y - y
        return (dx * dx + dy * dy).squareRoot()
    }
}

extension Point: CustomStringConvertible {
    public var description: String {
        "(\(x), \(y))"
    }
}
