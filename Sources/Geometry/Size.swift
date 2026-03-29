public struct Size: Hashable, Equatable, Codable, Sendable {
    public static let zero = Size(width: 0, height: 0)

    public var width: GeometryUnit
    public var height: GeometryUnit

    public var area: GeometryUnit { width * height }

    public init(width: GeometryUnit, height: GeometryUnit) {
        self.width = width
        self.height = height
    }

    public static func + (lhs: Size, rhs: Size) -> Size {
        return Size(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
    }

    public static func - (lhs: Size, rhs: Size) -> Size {
        return Size(width: lhs.width - rhs.width, height: lhs.height - rhs.height)
    }

    public static func * (lhs: Size, rhs: GeometryUnit) -> Size {
        return Size(width: lhs.width * rhs, height: lhs.height * rhs)
    }

    public static func / (lhs: Size, rhs: GeometryUnit) -> Size {
        return Size(width: lhs.width / rhs, height: lhs.height / rhs)
    }
}

extension Size: CustomStringConvertible {
    public var description: String {
        "(\(width), \(height))"
    }
}
