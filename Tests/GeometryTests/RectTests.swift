import Foundation
import Geometry
import Testing

// MARK: - Rect Initialization Tests

@Test
func `Rect Init With Origin And Size`() {
    let origin = Point(x: 10, y: 20)
    let size = Size(width: 100, height: 50)
    let rect = Rect(origin: origin, size: size)

    #expect(rect.origin == origin)
    #expect(rect.size == size)
}

@Test
func `Rect Init With Coordinates`() {
    let rect = Rect(x: 5, y: 15, width: 80, height: 60)

    #expect(rect.origin.x == 5)
    #expect(rect.origin.y == 15)
    #expect(rect.size.width == 80)
    #expect(rect.size.height == 60)
}

// MARK: - Computed Properties Tests

@Test
func `Rect Computed Properties`() {
    let rect = Rect(x: 10, y: 20, width: 100, height: 50)

    // Basic coordinates
    #expect(rect.x == 10)
    #expect(rect.y == 20)

    // Min coordinates
    #expect(rect.minX == 10)
    #expect(rect.minY == 20)

    // Max coordinates
    #expect(rect.maxX == 110)  // 10 + 100
    #expect(rect.maxY == 70)  // 20 + 50

    // Mid coordinates
    #expect(rect.midX == 60)  // 10 + 100/2
    #expect(rect.midY == 45)  // 20 + 50/2
}

@Test
func `Rect Computed Properties With Zero Size`() {
    let rect = Rect(x: 5, y: 10, width: 0, height: 0)

    #expect(rect.minX == 5)
    #expect(rect.minY == 10)
    #expect(rect.maxX == 5)
    #expect(rect.maxY == 10)
    #expect(rect.midX == 5)
    #expect(rect.midY == 10)
}

@Test
func `Rect Computed Properties With Negative Origin`() {
    let rect = Rect(x: -10, y: -20, width: 30, height: 40)

    #expect(rect.minX == -10)
    #expect(rect.minY == -20)
    #expect(rect.maxX == 20)  // -10 + 30
    #expect(rect.maxY == 20)  // -20 + 40
    #expect(rect.midX == 5)  // -10 + 30/2
    #expect(rect.midY == 0)  // -20 + 40/2
}

// MARK: - Contains Point Tests

@Test
func `Contains Point Inside`() {
    let rect = Rect(x: 10, y: 20, width: 100, height: 50)

    // Points clearly inside
    #expect(rect.contains(Point(x: 50, y: 40)))
    #expect(rect.contains(Point(x: 15, y: 25)))
    #expect(rect.contains(Point(x: 100, y: 60)))
}

@Test
func `Contains Point On Boundary`() {
    let rect = Rect(x: 10, y: 20, width: 100, height: 50)

    // Points on the boundary (inclusive)
    #expect(rect.contains(Point(x: 10, y: 20)))  // min corner
    #expect(rect.contains(Point(x: 110, y: 70)))  // max corner
    #expect(rect.contains(Point(x: 10, y: 45)))  // left edge
    #expect(rect.contains(Point(x: 110, y: 45)))  // right edge
    #expect(rect.contains(Point(x: 60, y: 20)))  // top edge
    #expect(rect.contains(Point(x: 60, y: 70)))  // bottom edge
}

@Test
func `Contains Point Outside`() {
    let rect = Rect(x: 10, y: 20, width: 100, height: 50)

    // Points clearly outside
    #expect(!rect.contains(Point(x: 5, y: 40)))  // left of rect
    #expect(!rect.contains(Point(x: 120, y: 40)))  // right of rect
    #expect(!rect.contains(Point(x: 50, y: 15)))  // above rect
    #expect(!rect.contains(Point(x: 50, y: 80)))  // below rect

    // Corner points just outside
    #expect(!rect.contains(Point(x: 9, y: 19)))  // before min corner
    #expect(!rect.contains(Point(x: 111, y: 71)))  // after max corner
}

@Test
func `Contains Point Zero Size Rect`() {
    let rect = Rect(x: 5, y: 10, width: 0, height: 0)

    // Only the exact point should be contained
    #expect(rect.contains(Point(x: 5, y: 10)))
    #expect(!rect.contains(Point(x: 5.1, y: 10)))
    #expect(!rect.contains(Point(x: 5, y: 10.1)))
    #expect(!rect.contains(Point(x: 4.9, y: 10)))
}

// MARK: - Intersection Tests

@Test
func `Intersects With Overlapping Rects`() {
    let rect1 = Rect(x: 10, y: 20, width: 100, height: 50)
    let rect2 = Rect(x: 50, y: 40, width: 80, height: 60)

    #expect(rect1.intersects(with: rect2))
    #expect(rect2.intersects(with: rect1))  // Should be symmetric
}

@Test
func `Intersects With Touching Rects`() {
    let rect1 = Rect(x: 10, y: 20, width: 100, height: 50)

    // Rects touching on edges
    let rightTouching = Rect(x: 110, y: 30, width: 50, height: 20)
    let leftTouching = Rect(x: 0, y: 30, width: 10, height: 20)
    let topTouching = Rect(x: 30, y: 10, width: 20, height: 10)
    let bottomTouching = Rect(x: 30, y: 70, width: 20, height: 10)

    // Touching rects should intersect
    #expect(rect1.intersects(with: rightTouching))
    #expect(rect1.intersects(with: leftTouching))
    #expect(rect1.intersects(with: topTouching))
    #expect(rect1.intersects(with: bottomTouching))
}

@Test
func `Intersects With Non Overlapping Rects`() {
    let rect1 = Rect(x: 10, y: 20, width: 100, height: 50)

    // Rects that don't overlap
    let rightSeparate = Rect(x: 120, y: 30, width: 50, height: 20)
    let leftSeparate = Rect(x: -50, y: 30, width: 50, height: 20)
    let topSeparate = Rect(x: 30, y: 0, width: 20, height: 15)
    let bottomSeparate = Rect(x: 30, y: 80, width: 20, height: 15)

    #expect(!rect1.intersects(with: rightSeparate))
    #expect(!rect1.intersects(with: leftSeparate))
    #expect(!rect1.intersects(with: topSeparate))
    #expect(!rect1.intersects(with: bottomSeparate))
}

@Test
func `Intersects With Identical Rects`() {
    let rect1 = Rect(x: 10, y: 20, width: 100, height: 50)
    let rect2 = Rect(x: 10, y: 20, width: 100, height: 50)

    #expect(rect1.intersects(with: rect2))
}

@Test
func `Intersects With Contained Rects`() {
    let outerRect = Rect(x: 10, y: 20, width: 100, height: 50)
    let innerRect = Rect(x: 30, y: 30, width: 40, height: 20)

    #expect(outerRect.intersects(with: innerRect))
    #expect(innerRect.intersects(with: outerRect))
}

@Test
func `Intersects With Zero Size Rects`() {
    let normalRect = Rect(x: 10, y: 20, width: 100, height: 50)
    let pointRect = Rect(x: 50, y: 40, width: 0, height: 0)
    let outsidePointRect = Rect(x: 5, y: 15, width: 0, height: 0)

    // Point inside should intersect
    #expect(normalRect.intersects(with: pointRect))
    #expect(pointRect.intersects(with: normalRect))

    // Point outside should not intersect
    #expect(!normalRect.intersects(with: outsidePointRect))
    #expect(!outsidePointRect.intersects(with: normalRect))
}

// MARK: - Intersection Calculation Tests

@Test
func `Intersection With Overlapping Rects`() {
    let rect1 = Rect(x: 10, y: 20, width: 100, height: 50)
    let rect2 = Rect(x: 50, y: 40, width: 80, height: 60)

    let intersection = rect1.intersection(with: rect2)

    #expect(intersection != nil)
    #expect(intersection?.x == 50)
    #expect(intersection?.y == 40)
    #expect(intersection?.size.width == 60)  // min(110, 130) - 50 = 60
    #expect(intersection?.size.height == 30)  // min(70, 100) - 40 = 30
}

@Test
func `Intersection With Non Overlapping Rects`() {
    let rect1 = Rect(x: 10, y: 20, width: 100, height: 50)
    let rect2 = Rect(x: 150, y: 80, width: 50, height: 30)

    let intersection = rect1.intersection(with: rect2)

    #expect(intersection == nil)
}

@Test
func `Intersection With Touching Rects`() {
    let rect1 = Rect(x: 10, y: 20, width: 100, height: 50)

    // Rects touching on edges should have zero-area intersection
    let rightTouching = Rect(x: 110, y: 30, width: 50, height: 20)
    let bottomTouching = Rect(x: 30, y: 70, width: 20, height: 10)

    let rightIntersection = rect1.intersection(with: rightTouching)
    let bottomIntersection = rect1.intersection(with: bottomTouching)

    #expect(rightIntersection != nil)
    #expect(rightIntersection?.size.width == 0)
    #expect(rightIntersection?.size.height == 20)

    #expect(bottomIntersection != nil)
    #expect(bottomIntersection?.size.width == 20)
    #expect(bottomIntersection?.size.height == 0)
}

@Test
func `Intersection With Identical Rects`() {
    let rect1 = Rect(x: 10, y: 20, width: 100, height: 50)
    let rect2 = Rect(x: 10, y: 20, width: 100, height: 50)

    let intersection = rect1.intersection(with: rect2)

    #expect(intersection == rect1)
    #expect(intersection == rect2)
}

@Test
func `Intersection With Contained Rects`() {
    let outerRect = Rect(x: 10, y: 20, width: 100, height: 50)
    let innerRect = Rect(x: 30, y: 30, width: 40, height: 20)

    let intersection1 = outerRect.intersection(with: innerRect)
    let intersection2 = innerRect.intersection(with: outerRect)

    // When one rect is contained in another, intersection should be the inner rect
    #expect(intersection1 == innerRect)
    #expect(intersection2 == innerRect)
}

@Test
func `Intersection With Zero Size Rects`() {
    let normalRect = Rect(x: 10, y: 20, width: 100, height: 50)
    let pointRect = Rect(x: 50, y: 40, width: 0, height: 0)
    let outsidePointRect = Rect(x: 5, y: 15, width: 0, height: 0)

    // Point inside should have zero-area intersection at that point
    let insideIntersection = normalRect.intersection(with: pointRect)
    #expect(insideIntersection == pointRect)

    // Point outside should have no intersection
    let outsideIntersection = normalRect.intersection(with: outsidePointRect)
    #expect(outsideIntersection == nil)
}

@Test
func `Intersection Partial Overlap Cases`() {
    let baseRect = Rect(x: 10, y: 20, width: 100, height: 50)

    // Overlapping from the right
    let rightOverlap = Rect(x: 80, y: 30, width: 60, height: 30)
    let rightIntersection = baseRect.intersection(with: rightOverlap)
    #expect(rightIntersection?.x == 80)
    #expect(rightIntersection?.y == 30)
    #expect(rightIntersection?.size.width == 30)  // 110 - 80
    #expect(rightIntersection?.size.height == 30)

    // Overlapping from the left
    let leftOverlap = Rect(x: -10, y: 30, width: 40, height: 30)
    let leftIntersection = baseRect.intersection(with: leftOverlap)
    #expect(leftIntersection?.x == 10)
    #expect(leftIntersection?.y == 30)
    #expect(leftIntersection?.size.width == 20)  // 30 - 10
    #expect(leftIntersection?.size.height == 30)

    // Overlapping from the top
    let topOverlap = Rect(x: 30, y: 0, width: 40, height: 40)
    let topIntersection = baseRect.intersection(with: topOverlap)
    #expect(topIntersection?.x == 30)
    #expect(topIntersection?.y == 20)
    #expect(topIntersection?.size.width == 40)
    #expect(topIntersection?.size.height == 20)  // 40 - 20

    // Overlapping from the bottom
    let bottomOverlap = Rect(x: 30, y: 50, width: 40, height: 40)
    let bottomIntersection = baseRect.intersection(with: bottomOverlap)
    #expect(bottomIntersection?.x == 30)
    #expect(bottomIntersection?.y == 50)
    #expect(bottomIntersection?.size.width == 40)
    #expect(bottomIntersection?.size.height == 20)  // 70 - 50
}

@Test
func `Intersection Is Symmetric`() {
    let rect1 = Rect(x: 10, y: 20, width: 100, height: 50)
    let rect2 = Rect(x: 50, y: 40, width: 80, height: 60)

    let intersection1 = rect1.intersection(with: rect2)
    let intersection2 = rect2.intersection(with: rect1)

    // Intersection should be symmetric
    #expect(intersection1 == intersection2)
}

// MARK: - Protocol Conformance Tests

@Test
func `Rect Equality`() {
    let rect1 = Rect(x: 10, y: 20, width: 100, height: 50)
    let rect2 = Rect(x: 10, y: 20, width: 100, height: 50)
    let rect3 = Rect(x: 10, y: 20, width: 101, height: 50)

    #expect(rect1 == rect2)
    #expect(rect1 != rect3)
}

@Test
func `Rect Hashable`() {
    let rect1 = Rect(x: 10, y: 20, width: 100, height: 50)
    let rect2 = Rect(x: 10, y: 20, width: 100, height: 50)

    #expect(rect1.hashValue == rect2.hashValue)
}

@Test
func `Rect Codable`() throws {
    let originalRect = Rect(x: 10.5, y: 20.7, width: 100.3, height: 50.9)

    let encoder = JSONEncoder()
    let decoder = JSONDecoder()

    let data = try encoder.encode(originalRect)
    let decodedRect = try decoder.decode(Rect.self, from: data)

    #expect(decodedRect == originalRect)
}
