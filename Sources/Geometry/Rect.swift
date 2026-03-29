public struct Rect: Hashable, Equatable, Codable, Sendable {
    public static let zero: Rect = .init(x: 0, y: 0, width: 0, height: 0)

    public var origin: Point
    public var size: Size

    public var x: GeometryUnit { origin.x }
    public var y: GeometryUnit { origin.y }
    public var width: GeometryUnit { size.width }
    public var height: GeometryUnit { size.height }
    public var minX: GeometryUnit { origin.x }
    public var minY: GeometryUnit { origin.y }
    public var maxX: GeometryUnit { origin.x + size.width }
    public var maxY: GeometryUnit { origin.y + size.height }
    public var midX: GeometryUnit { origin.x + size.width / 2 }
    public var midY: GeometryUnit { origin.y + size.height / 2 }

    public init(origin: Point, size: Size) {
        self.origin = origin
        self.size = size
    }

    public init(
        x: GeometryUnit,
        y: GeometryUnit,
        width: GeometryUnit,
        height: GeometryUnit
    ) {
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

        let intersectionMinX: GeometryUnit = max(minX, other.minX)
        let intersectionMinY: GeometryUnit = max(minY, other.minY)
        let intersectionMaxX: GeometryUnit = min(maxX, other.maxX)
        let intersectionMaxY: GeometryUnit = min(maxY, other.maxY)

        return Rect(
            x: intersectionMinX,
            y: intersectionMinY,
            width: intersectionMaxX - intersectionMinX,
            height: intersectionMaxY - intersectionMinY
        )
    }

    public func union(_ other: Rect) -> Rect {
        let unionMinX: GeometryUnit = min(minX, other.minX)
        let unionMinY: GeometryUnit = min(minY, other.minY)
        let unionMaxX: GeometryUnit = max(maxX, other.maxX)
        let unionMaxY: GeometryUnit = max(maxY, other.maxY)

        return Rect(
            x: unionMinX,
            y: unionMinY,
            width: unionMaxX - unionMinX,
            height: unionMaxY - unionMinY
        )
    }

    public func offsetBy(
        dx: GeometryUnit,
        dy: GeometryUnit
    ) -> Rect {
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
