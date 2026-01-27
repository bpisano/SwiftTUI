import Foundation
import Geometry
import Testing

// MARK: - Size Initialization Tests

@Test
func `Size Init With Dimensions`() {
    let size = Size(width: 100.5, height: 50.7)

    #expect(size.width == 100.5)
    #expect(size.height == 50.7)
}

@Test
func `Size Zero Static Property`() {
    let zero = Size.zero

    #expect(zero.width == 0)
    #expect(zero.height == 0)
    #expect(zero == Size(width: 0, height: 0))
}

// MARK: - Area Calculation Tests

@Test
func `Size Area Calculation`() {
    let size = Size(width: 10, height: 5)

    #expect(size.area == 50)
}

@Test
func `Size Area With Decimal Values`() {
    let size = Size(width: 2.5, height: 4.0)

    #expect(size.area == 10.0)
}

@Test
func `Size Area With Zero Width`() {
    let size = Size(width: 0, height: 10)

    #expect(size.area == 0)
}

@Test
func `Size Area With Zero Height`() {
    let size = Size(width: 10, height: 0)

    #expect(size.area == 0)
}

@Test
func `Size Area With Zero Dimensions`() {
    let size = Size.zero

    #expect(size.area == 0)
}

@Test
func `Size Area With Negative Width`() {
    let size = Size(width: -10, height: 5)

    #expect(size.area == -50)
}

@Test
func `Size Area With Negative Height`() {
    let size = Size(width: 10, height: -5)

    #expect(size.area == -50)
}

@Test
func `Size Area With Both Negative`() {
    let size = Size(width: -10, height: -5)

    #expect(size.area == 50)
}

// MARK: - Size Arithmetic Tests

@Test
func `Size Addition`() {
    let size1 = Size(width: 10, height: 20)
    let size2 = Size(width: 5, height: 15)

    let result = size1 + size2

    #expect(result.width == 15)
    #expect(result.height == 35)
}

@Test
func `Size Addition With Zero`() {
    let size = Size(width: 10, height: 20)
    let zero = Size.zero

    let result = size + zero

    #expect(result == size)
}

@Test
func `Size Addition With Negative Values`() {
    let size1 = Size(width: 10, height: 20)
    let size2 = Size(width: -5, height: -15)

    let result = size1 + size2

    #expect(result.width == 5)
    #expect(result.height == 5)
}

@Test
func `Size Subtraction`() {
    let size1 = Size(width: 20, height: 30)
    let size2 = Size(width: 5, height: 10)

    let result = size1 - size2

    #expect(result.width == 15)
    #expect(result.height == 20)
}

@Test
func `Size Subtraction With Negative Result`() {
    let size1 = Size(width: 5, height: 10)
    let size2 = Size(width: 20, height: 30)

    let result = size1 - size2

    #expect(result.width == -15)
    #expect(result.height == -20)
}

@Test
func `Size Subtraction Self`() {
    let size = Size(width: 10, height: 20)

    let result = size - size

    #expect(result == Size.zero)
}

@Test
func `Size Multiplication By Scalar`() {
    let size = Size(width: 10, height: 20)
    let scalar = 2.5

    let result = size * scalar

    #expect(result.width == 25)
    #expect(result.height == 50)
}

@Test
func `Size Multiplication By Zero`() {
    let size = Size(width: 10, height: 20)

    let result = size * 0

    #expect(result == Size.zero)
}

@Test
func `Size Multiplication By Negative Scalar`() {
    let size = Size(width: 10, height: 20)

    let result = size * -2

    #expect(result.width == -20)
    #expect(result.height == -40)
}

@Test
func `Size Division By Scalar`() {
    let size = Size(width: 20, height: 40)
    let scalar = 4.0

    let result = size / scalar

    #expect(result.width == 5)
    #expect(result.height == 10)
}

@Test
func `Size Division By Negative Scalar`() {
    let size = Size(width: 20, height: 40)

    let result = size / -2

    #expect(result.width == -10)
    #expect(result.height == -20)
}

@Test
func `Size Division By Fractional Scalar`() {
    let size = Size(width: 10, height: 20)

    let result = size / 0.5

    #expect(result.width == 20)
    #expect(result.height == 40)
}

// MARK: - Protocol Conformance Tests

@Test
func `Size Equality`() {
    let size1 = Size(width: 10.5, height: 20.7)
    let size2 = Size(width: 10.5, height: 20.7)
    let size3 = Size(width: 10.5, height: 20.8)

    #expect(size1 == size2)
    #expect(size1 != size3)
}

@Test
func `Size Hashable`() {
    let size1 = Size(width: 10, height: 20)
    let size2 = Size(width: 10, height: 20)

    #expect(size1.hashValue == size2.hashValue)
}

@Test
func `Size Codable`() throws {
    let originalSize = Size(width: 10.5, height: 20.7)

    let encoder = JSONEncoder()
    let decoder = JSONDecoder()

    let data = try encoder.encode(originalSize)
    let decodedSize = try decoder.decode(Size.self, from: data)

    #expect(decodedSize == originalSize)
}

// MARK: - Edge Cases Tests

@Test
func `Size With Very Large Values`() {
    let size = Size(width: Double.greatestFiniteMagnitude, height: Double.greatestFiniteMagnitude)

    #expect(size.width == Double.greatestFiniteMagnitude)
    #expect(size.height == Double.greatestFiniteMagnitude)
}

@Test
func `Size With Very Small Values`() {
    let size = Size(width: Double.leastNormalMagnitude, height: Double.leastNormalMagnitude)

    #expect(size.width == Double.leastNormalMagnitude)
    #expect(size.height == Double.leastNormalMagnitude)
}

@Test
func `Size Arithmetic Commutativity`() {
    let size1 = Size(width: 10, height: 20)
    let size2 = Size(width: 5, height: 15)

    // Addition is commutative
    #expect(size1 + size2 == size2 + size1)
}

@Test
func `Size Arithmetic Associativity`() {
    let size1 = Size(width: 10, height: 20)
    let size2 = Size(width: 5, height: 15)
    let size3 = Size(width: 3, height: 7)

    // Addition is associative
    #expect((size1 + size2) + size3 == size1 + (size2 + size3))
}

// MARK: - Scaling and Transformation Tests

@Test
func `Size Scaling Preserves Aspect Ratio`() {
    let originalSize = Size(width: 16, height: 9)  // 16:9 aspect ratio
    let scaledSize = originalSize * 2

    let originalRatio = originalSize.width / originalSize.height
    let scaledRatio = scaledSize.width / scaledSize.height

    #expect(abs(originalRatio - scaledRatio) < 0.000001)
}

@Test
func `Size Area After Scaling`() {
    let originalSize = Size(width: 10, height: 5)
    let scaledSize = originalSize * 3

    let originalArea = originalSize.area
    let scaledArea = scaledSize.area

    // Area should scale by the square of the scale factor
    #expect(scaledArea == originalArea * 9)  // 3²
}

@Test
func `Size Unit Square`() {
    let unitSquare = Size(width: 1, height: 1)

    #expect(unitSquare.area == 1)
    #expect(unitSquare * 5 == Size(width: 5, height: 5))
}

@Test
func `Size Inverse Operations`() {
    let originalSize = Size(width: 20, height: 30)
    let scalar = 4.0

    // Multiply then divide should give back original
    let result = (originalSize * scalar) / scalar

    #expect(abs(result.width - originalSize.width) < 0.000001)
    #expect(abs(result.height - originalSize.height) < 0.000001)
}
