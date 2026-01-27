import Foundation
import Geometry
import Testing

// MARK: - Point Initialization Tests

@Test
func `Point Init With Coordinates`() {
    let point = Point(x: 10.5, y: 20.7)

    #expect(point.x == 10.5)
    #expect(point.y == 20.7)
}

@Test
func `Point Zero Static Property`() {
    let zero = Point.zero

    #expect(zero.x == 0)
    #expect(zero.y == 0)
    #expect(zero == Point(x: 0, y: 0))
}

// MARK: - Point Arithmetic Tests

@Test
func `Point Addition`() {
    let point1 = Point(x: 10, y: 20)
    let point2 = Point(x: 5, y: 15)

    let result = point1 + point2

    #expect(result.x == 15)
    #expect(result.y == 35)
}

@Test
func `Point Addition With Negative Values`() {
    let point1 = Point(x: 10, y: 20)
    let point2 = Point(x: -5, y: -15)

    let result = point1 + point2

    #expect(result.x == 5)
    #expect(result.y == 5)
}

@Test
func `Point Addition With Zero`() {
    let point = Point(x: 10, y: 20)
    let zero = Point.zero

    let result = point + zero

    #expect(result == point)
}

@Test
func `Point Subtraction`() {
    let point1 = Point(x: 20, y: 30)
    let point2 = Point(x: 5, y: 10)

    let result = point1 - point2

    #expect(result.x == 15)
    #expect(result.y == 20)
}

@Test
func `Point Subtraction With Negative Result`() {
    let point1 = Point(x: 5, y: 10)
    let point2 = Point(x: 20, y: 30)

    let result = point1 - point2

    #expect(result.x == -15)
    #expect(result.y == -20)
}

@Test
func `Point Subtraction Self`() {
    let point = Point(x: 10, y: 20)

    let result = point - point

    #expect(result == Point.zero)
}

@Test
func `Point Multiplication By Scalar`() {
    let point = Point(x: 10, y: 20)
    let scalar = 2.5

    let result = point * scalar

    #expect(result.x == 25)
    #expect(result.y == 50)
}

@Test
func `Point Multiplication By Zero`() {
    let point = Point(x: 10, y: 20)

    let result = point * 0

    #expect(result == Point.zero)
}

@Test
func `Point Multiplication By Negative Scalar`() {
    let point = Point(x: 10, y: 20)

    let result = point * -2

    #expect(result.x == -20)
    #expect(result.y == -40)
}

@Test
func `Point Division By Scalar`() {
    let point = Point(x: 20, y: 40)
    let scalar = 4.0

    let result = point / scalar

    #expect(result.x == 5)
    #expect(result.y == 10)
}

@Test
func `Point Division By Negative Scalar`() {
    let point = Point(x: 20, y: 40)

    let result = point / -2

    #expect(result.x == -10)
    #expect(result.y == -20)
}

@Test
func `Point Division By Fractional Scalar`() {
    let point = Point(x: 10, y: 20)

    let result = point / 0.5

    #expect(result.x == 20)
    #expect(result.y == 40)
}

// MARK: - Distance Calculation Tests

@Test
func `Distance To Same Point`() {
    let point = Point(x: 10, y: 20)

    let distance = point.distance(to: point)

    #expect(distance == 0)
}

@Test
func `Distance To Point On Same X Axis`() {
    let point1 = Point(x: 0, y: 0)
    let point2 = Point(x: 5, y: 0)

    let distance = point1.distance(to: point2)

    #expect(distance == 5)
}

@Test
func `Distance To Point On Same Y Axis`() {
    let point1 = Point(x: 0, y: 0)
    let point2 = Point(x: 0, y: 12)

    let distance = point1.distance(to: point2)

    #expect(distance == 12)
}

@Test
func `Distance Pythagorean Triple`() {
    let point1 = Point(x: 0, y: 0)
    let point2 = Point(x: 3, y: 4)

    let distance = point1.distance(to: point2)

    #expect(distance == 5)  // 3-4-5 triangle
}

@Test
func `Distance With Negative Coordinates`() {
    let point1 = Point(x: -3, y: -4)
    let point2 = Point(x: 0, y: 0)

    let distance = point1.distance(to: point2)

    #expect(distance == 5)  // Same 3-4-5 triangle
}

@Test
func `Distance Is Symmetric`() {
    let point1 = Point(x: 10, y: 20)
    let point2 = Point(x: 13, y: 24)

    let distance1 = point1.distance(to: point2)
    let distance2 = point2.distance(to: point1)

    #expect(distance1 == distance2)
}

@Test
func `Distance With Decimal Values`() {
    let point1 = Point(x: 1.0, y: 1.0)
    let point2 = Point(x: 2.0, y: 2.0)

    let distance = point1.distance(to: point2)
    let expected = (2.0).squareRoot()  // √2

    #expect(abs(distance - expected) < 0.000001)
}

// MARK: - Protocol Conformance Tests

@Test
func `Point Equality`() {
    let point1 = Point(x: 10.5, y: 20.7)
    let point2 = Point(x: 10.5, y: 20.7)
    let point3 = Point(x: 10.5, y: 20.8)

    #expect(point1 == point2)
    #expect(point1 != point3)
}

@Test
func `Point Hashable`() {
    let point1 = Point(x: 10, y: 20)
    let point2 = Point(x: 10, y: 20)

    #expect(point1.hashValue == point2.hashValue)
}

@Test
func `Point Codable`() throws {
    let originalPoint = Point(x: 10.5, y: 20.7)

    let encoder = JSONEncoder()
    let decoder = JSONDecoder()

    let data = try encoder.encode(originalPoint)
    let decodedPoint = try decoder.decode(Point.self, from: data)

    #expect(decodedPoint == originalPoint)
}

// MARK: - Edge Cases Tests

@Test
func `Point With Very Large Values`() {
    let point = Point(x: Double.greatestFiniteMagnitude, y: Double.greatestFiniteMagnitude)

    #expect(point.x == Double.greatestFiniteMagnitude)
    #expect(point.y == Double.greatestFiniteMagnitude)
}

@Test
func `Point With Very Small Values`() {
    let point = Point(x: Double.leastNormalMagnitude, y: Double.leastNormalMagnitude)

    #expect(point.x == Double.leastNormalMagnitude)
    #expect(point.y == Double.leastNormalMagnitude)
}

@Test
func `Point Arithmetic Commutativity`() {
    let point1 = Point(x: 10, y: 20)
    let point2 = Point(x: 5, y: 15)

    // Addition is commutative
    #expect(point1 + point2 == point2 + point1)
}

@Test
func `Point Arithmetic Associativity`() {
    let point1 = Point(x: 10, y: 20)
    let point2 = Point(x: 5, y: 15)
    let point3 = Point(x: 3, y: 7)

    // Addition is associative
    #expect((point1 + point2) + point3 == point1 + (point2 + point3))
}
