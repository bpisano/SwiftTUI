
#if canImport(XCTest)
import Foundation
import AttributeGraph
import XCTest

@MainActor
final class PerformanceBenchmarkTests: XCTestCase {

    // MARK: - Deep linear chain

    func testDeepChain1000InitialEvaluation() {
        let graph = Graph()
        graph.makeCurrent()

        let depth = 1_000
        @Attribute var source: Int = 0

        var chain: [Attribute<Int>] = [$source]
        for _ in 0..<depth {
            let prev = chain.last!
            chain.append(Attribute { prev.wrappedValue + 1 })
        }
        let leaf = chain.last!

        let options = XCTMeasureOptions()
        options.iterationCount = 10
        measure(metrics: [XCTClockMetric(), XCTMemoryMetric()], options: options) {
            for node in chain { _ = node.wrappedValue }
        }

        XCTAssertEqual(leaf.wrappedValue, depth)
    }

    func testDeepChain1000ReEvaluationAfterSourceChange() {
        let graph = Graph()
        graph.makeCurrent()

        let depth = 1_000
        @Attribute var source: Int = 0

        var chain: [Attribute<Int>] = [$source]
        for _ in 0..<depth {
            let prev = chain.last!
            chain.append(Attribute { prev.wrappedValue + 1 })
        }
        let leaf = chain.last!
        for node in chain { _ = node.wrappedValue }

        let options = XCTMeasureOptions()
        options.iterationCount = 10
        measure(metrics: [XCTClockMetric(), XCTMemoryMetric()], options: options) {
            source += 1
            _ = leaf.wrappedValue
        }

        // Derive expected from actual final state: leaf always equals source + depth
        XCTAssertEqual(leaf.wrappedValue, source + depth)
    }

    func testDeepChain1000NoOpWrite() {
        let graph = Graph()
        graph.makeCurrent()

        let depth = 1_000
        @Attribute var source: Int = 0

        var chain: [Attribute<Int>] = [$source]
        for _ in 0..<depth {
            let prev = chain.last!
            chain.append(Attribute { prev.wrappedValue + 1 })
        }
        let leaf = chain.last!
        for node in chain { _ = node.wrappedValue }

        var evalCount = 0
        let tracked = Attribute {
            evalCount += 1
            return leaf.wrappedValue
        }
        _ = tracked.wrappedValue
        let initCount = evalCount

        let options = XCTMeasureOptions()
        options.iterationCount = 10
        measure(metrics: [XCTClockMetric(), XCTMemoryMetric()], options: options) {
            source = 0  // same value every time → equality short-circuit fires immediately
            _ = tracked.wrappedValue
        }

        XCTAssertEqual(evalCount, initCount, "No node should re-evaluate when source value is unchanged")
    }

    // MARK: - Wide fan-out

    func testWideFanOut5000InitialEvaluation() {
        let graph = Graph()
        graph.makeCurrent()

        let width = 5_000
        @Attribute var source: Int = 1

        let leaves: [Attribute<Int>] = (0..<width).map { i in
            Attribute { source * (i + 1) }
        }

        var sum = 0
        let options = XCTMeasureOptions()
        options.iterationCount = 10
        measure(metrics: [XCTClockMetric(), XCTMemoryMetric()], options: options) {
            sum = leaves.reduce(0) { $0 + $1.wrappedValue }
        }

        // sum = 1×1 + 1×2 + … + 1×5000 = 5000×5001/2
        let expected = width * (width + 1) / 2
        XCTAssertEqual(sum, expected)
    }

    func testWideFanOut5000ReEvaluationAfterSourceChange() {
        let graph = Graph()
        graph.makeCurrent()

        let width = 5_000
        @Attribute var source: Int = 1

        let leaves: [Attribute<Int>] = (0..<width).map { i in
            Attribute { source * (i + 1) }
        }
        _ = leaves.reduce(0) { $0 + $1.wrappedValue }  // prime

        let options = XCTMeasureOptions()
        options.iterationCount = 10
        measure(metrics: [XCTClockMetric(), XCTMemoryMetric()], options: options) {
            source += 1
            _ = leaves.reduce(0) { $0 + $1.wrappedValue }
        }

        // Derive expected from actual final source value — correct regardless of iteration count
        let expected = (1...width).reduce(0) { $0 + $1 * source }
        XCTAssertEqual(leaves.reduce(0) { $0 + $1.wrappedValue }, expected)
    }

    // MARK: - Binary tree

    func testBinaryTree1024LeavesInitialEvaluation() {
        let graph = Graph()
        graph.makeCurrent()

        let leafCount = 1 << 10  // 1024
        @Attribute var source: Int = 0

        var level: [Attribute<Int>] = (0..<leafCount).map { _ in
            Attribute { source + 1 }
        }
        while level.count > 1 {
            var next: [Attribute<Int>] = []
            for i in stride(from: 0, to: level.count, by: 2) {
                let l = level[i]; let r = level[i + 1]
                next.append(Attribute { l.wrappedValue + r.wrappedValue })
            }
            level = next
        }
        let root = level[0]

        let options = XCTMeasureOptions()
        options.iterationCount = 10
        measure(metrics: [XCTClockMetric(), XCTMemoryMetric()], options: options) {
            _ = root.wrappedValue
        }

        XCTAssertEqual(root.wrappedValue, leafCount)
    }

    func testBinaryTree1024LeavesReEvaluationAfterSourceChange() {
        let graph = Graph()
        graph.makeCurrent()

        let leafCount = 1 << 10  // 1024
        @Attribute var source: Int = 0

        var level: [Attribute<Int>] = (0..<leafCount).map { _ in
            Attribute { source + 1 }
        }
        while level.count > 1 {
            var next: [Attribute<Int>] = []
            for i in stride(from: 0, to: level.count, by: 2) {
                let l = level[i]; let r = level[i + 1]
                next.append(Attribute { l.wrappedValue + r.wrappedValue })
            }
            level = next
        }
        let root = level[0]
        _ = root.wrappedValue  // prime

        let options = XCTMeasureOptions()
        options.iterationCount = 10
        measure(metrics: [XCTClockMetric(), XCTMemoryMetric()], options: options) {
            source += 1
            _ = root.wrappedValue
        }

        // Derive expected from actual final source value — correct regardless of iteration count
        XCTAssertEqual(root.wrappedValue, leafCount * (source + 1))
    }

    // MARK: - Pending cut (no-op clamp)

    func testPendingCut1000DownstreamNodesSkippedAfterNoOpClamp() {
        let graph = Graph()
        graph.makeCurrent()

        let depth = 1_000
        @Attribute var source: Int = 10  // already at clamp boundary

        let clamped = Attribute { min(max(source, 0), 10) }

        var previous = clamped
        for _ in 0..<depth {
            let prev = previous
            previous = Attribute { prev.wrappedValue + 1 }
        }
        let leaf = previous
        _ = leaf.wrappedValue  // prime

        var evalCount = 0
        let tracked = Attribute {
            evalCount += 1
            return leaf.wrappedValue
        }
        _ = tracked.wrappedValue
        let initCount = evalCount

        let options = XCTMeasureOptions()
        options.iterationCount = 10
        measure(metrics: [XCTClockMetric(), XCTMemoryMetric()], options: options) {
            source += 1  // clamp(11+, 0…10) == 10 → downstream unchanged
            _ = tracked.wrappedValue
        }

        XCTAssertEqual(evalCount, initCount, "No downstream node should re-evaluate: clamped value is unchanged")
        XCTAssertEqual(tracked.wrappedValue, 10 + depth)
    }

    // MARK: - Multi-diamond lattice

    func testMultiDiamond64x8InitialEvaluation() {
        let graph = Graph()
        graph.makeCurrent()

        let width = 64
        let layers = 8
        @Attribute var source: Int = 1

        var layer: [Attribute<Int>] = (0..<width).map { i in Attribute { source + i } }
        for _ in 1..<layers {
            var next: [Attribute<Int>] = []
            for i in 0..<layer.count {
                let left = layer[i]; let right = layer[(i + 1) % layer.count]
                next.append(Attribute { left.wrappedValue + right.wrappedValue })
            }
            layer = next
        }
        let root = Attribute { layer.reduce(0) { $0 + $1.wrappedValue } }

        let options = XCTMeasureOptions()
        options.iterationCount = 10
        measure(metrics: [XCTClockMetric(), XCTMemoryMetric()], options: options) {
            _ = root.wrappedValue
        }

        XCTAssertGreaterThan(root.wrappedValue, 0)
    }

    func testMultiDiamond64x8ReEvaluationAfterSourceChange() {
        let graph = Graph()
        graph.makeCurrent()

        let width = 64
        let layers = 8
        @Attribute var source: Int = 1

        var layer: [Attribute<Int>] = (0..<width).map { i in Attribute { source + i } }
        for _ in 1..<layers {
            var next: [Attribute<Int>] = []
            for i in 0..<layer.count {
                let left = layer[i]; let right = layer[(i + 1) % layer.count]
                next.append(Attribute { left.wrappedValue + right.wrappedValue })
            }
            layer = next
        }
        let root = Attribute { layer.reduce(0) { $0 + $1.wrappedValue } }
        _ = root.wrappedValue
        let initialValue = root.wrappedValue

        let options = XCTMeasureOptions()
        options.iterationCount = 10
        measure(metrics: [XCTClockMetric(), XCTMemoryMetric()], options: options) {
            source += 1
            _ = root.wrappedValue
        }

        XCTAssertNotEqual(root.wrappedValue, initialValue)
    }

    // MARK: - Shared dependency deduplication

    func testSharedNodeEvaluatedOnceAcross500Dependents() {
        let graph = Graph()
        graph.makeCurrent()

        let width = 500
        var sharedEvalCount = 0
        @Attribute var source: Int = 0
        let shared = Attribute {
            sharedEvalCount += 1
            return source * 10
        }

        let leaves: [Attribute<Int>] = (0..<width).map { i in
            Attribute { shared.wrappedValue + i }
        }
        let root = Attribute { leaves.reduce(0) { $0 + $1.wrappedValue } }

        _ = root.wrappedValue
        let countAfterInit = sharedEvalCount

        var iterationsDone = 0
        let options = XCTMeasureOptions()
        options.iterationCount = 10
        measure(metrics: [XCTClockMetric(), XCTMemoryMetric()], options: options) {
            iterationsDone += 1
            source += 1
            _ = root.wrappedValue
        }

        // shared must be re-evaluated exactly once per iteration, regardless of iteration count
        XCTAssertEqual(sharedEvalCount, countAfterInit + iterationsDone,
                       "shared should be re-evaluated exactly once per source change, not once per dependent")

        // Derive expected from actual final source value
        let finalShared = source * 10
        let expectedRoot = (0..<width).reduce(0) { $0 + finalShared + $1 }
        XCTAssertEqual(root.wrappedValue, expectedRoot)
    }
}
#endif
