public struct Rect: Hashable, Equatable, Codable, Sendable {
    public static let zero: Rect = .init(x: 0, y: 0, width: 0, height: 0)
    public static let null: Rect = .init(x: .infinity, y: .infinity, width: -.infinity, height: -.infinity)

    public var origin: Point
    public var size: Size

    public var x: Double { origin.x }
    public var y: Double { origin.y }
    public var width: Double { size.width }
    public var height: Double { size.height }
    public var minX: Double { origin.x }
    public var minY: Double { origin.y }
    public var maxX: Double { origin.x + size.width }
    public var maxY: Double { origin.y + size.height }
    public var midX: Double { origin.x + size.width / 2 }
    public var midY: Double { origin.y + size.height / 2 }

    public init(origin: Point, size: Size) {
        self.origin = origin
        self.size = size
    }

    public init(x: Double, y: Double, width: Double, height: Double) {
        self.origin = Point(x: x, y: y)
        self.size = Size(width: width, height: height)
    }

    public func contains(_ point: Point) -> Bool {
        return point.x >= minX && point.x <= maxX && point.y >= minY && point.y <= maxY
    }

    public func intersects(with other: Rect) -> Bool {
        return !(other.minX > maxX || other.maxX < minX || other.minY > maxY || other.maxY < minY)
    }

    public func intersection(with other: Rect) -> Rect? {
        if !intersects(with: other) {
            return nil
        }

        let intersectionMinX: Double = max(minX, other.minX)
        let intersectionMinY: Double = max(minY, other.minY)
        let intersectionMaxX: Double = min(maxX, other.maxX)
        let intersectionMaxY: Double = min(maxY, other.maxY)

        return Rect(
            x: intersectionMinX,
            y: intersectionMinY,
            width: intersectionMaxX - intersectionMinX,
            height: intersectionMaxY - intersectionMinY
        )
    }

    public func union(_ other: Rect) -> Rect {
        let unionMinX: Double = min(minX, other.minX)
        let unionMinY: Double = min(minY, other.minY)
        let unionMaxX: Double = max(maxX, other.maxX)
        let unionMaxY: Double = max(maxY, other.maxY)

        return Rect(
            x: unionMinX,
            y: unionMinY,
            width: unionMaxX - unionMinX,
            height: unionMaxY - unionMinY
        )
    }

    public func offsetBy(dx: Double, dy: Double) -> Rect {
        Rect(
            x: origin.x + dx,
            y: origin.y + dy,
            width: size.width,
            height: size.height
        )
    }
}

extension Rect: CustomStringConvertible {
    public var description: String {
        "(\(x), \(y), \(size.width), \(size.height))"
    }
}
