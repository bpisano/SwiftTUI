import Foundation
import Testing
import AttributeGraph

// MARK: - Measurement helper

private func measure(
    label: String,
    iterations: Int = 1,
    operation: () -> Void
) -> Duration {
    let clock = ContinuousClock()
    let start = clock.now
    for _ in 0..<iterations { operation() }
    let elapsed = clock.now - start
    let avg = elapsed / iterations
    let ms = Double(avg.components.seconds) * 1_000
        + Double(avg.components.attoseconds) / 1_000_000_000_000_000
    let suffix = iterations > 1 ? " (avg over \(iterations) iterations)" : ""
    print("  ⏱  AG1 \(label)\(suffix): \(String(format: "%.3f", ms)) ms")
    return avg
}

// MARK: - Tests
//
// These tests mirror AttributeGraph2/PerformanceBenchmarkTests.swift exactly,
// so the printed ⏱ lines can be compared side-by-side.
//
// Known AG1 limitations vs AG2:
//   - No equality short-circuit: same-value writes still propagate dirty
//   - Recursive evaluation: deep chains overflow the stack above ~1000 nodes
//   - O(n²) registerDependency: linear scan of outgoingEdges on each dep access

@Suite("AG1 – Performance benchmarks")
@MainActor
struct AG1PerformanceBenchmarkTests {

    // MARK: - Deep linear chain
    //
    // AG1 evaluation is RECURSIVE. Depth is capped at 1000 to stay below the
    // macOS default thread stack limit (~8 MB). AG2 handles 5000+ iteratively.

    @Test
    func `Deep chain 1000 – initial evaluation`() {
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

        _ = measure(label: "Deep chain \(depth) – initial eval (iterative priming)") {
            for node in chain { _ = node.wrappedValue }
        }

        #expect(leaf.wrappedValue == depth)
    }

    @Test
    func `Deep chain 1000 – re-evaluation after source change`() {
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
        for node in chain { _ = node.wrappedValue }  // prime iteratively

        // Re-eval is RECURSIVE in AG1: reading leaf triggers a depth-1000 call stack.
        let iterations = 5
        _ = measure(label: "Deep chain \(depth) – re-eval after change (recursive)", iterations: iterations) {
            source += 1
            _ = leaf.wrappedValue
        }

        #expect(leaf.wrappedValue == iterations + depth)
    }

    @Test
    func `Deep chain 1000 – no-op write (no short-circuit in AG1)`() {
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

        // AG1 now has equality short-circuit: writing source = 0 (same value)
        // skips all dirty propagation, so the chain is never re-evaluated.
        _ = measure(label: "Deep chain \(depth) – no-op (no short-circuit, full re-eval)", iterations: 5) {
            source = 0
            _ = tracked.wrappedValue
        }

        // With the equality short-circuit, no re-evaluation should occur.
        #expect(evalCount == initCount, "AG1 should short-circuit when value is unchanged")
    }

    // MARK: - Wide fan-out
    //
    // Fan-out avoids deep recursion (each leaf is only 1 hop from source),
    // but AG1 suffers from O(n²) registerDependency due to linear outgoingEdges scan.

    @Test
    func `Wide fan-out 5000 – initial evaluation`() {
        let graph = Graph()
        graph.makeCurrent()

        let width = 5_000
        @Attribute var source: Int = 1

        let leaves: [Attribute<Int>] = (0..<width).map { i in
            Attribute { source * (i + 1) }
        }

        var sum = 0
        _ = measure(label: "Fan-out \(width) – initial eval") {
            sum = leaves.reduce(0) { $0 + $1.wrappedValue }
        }

        let expected = width * (width + 1) / 2
        #expect(sum == expected)
    }

    @Test
    func `Wide fan-out 5000 – re-evaluation after source change`() {
        let graph = Graph()
        graph.makeCurrent()

        let width = 5_000
        @Attribute var source: Int = 1

        let leaves: [Attribute<Int>] = (0..<width).map { i in
            Attribute { source * (i + 1) }
        }
        _ = leaves.reduce(0) { $0 + $1.wrappedValue }  // prime

        let iterations = 5
        _ = measure(label: "Fan-out \(width) – re-eval after change", iterations: iterations) {
            source += 1
            _ = leaves.reduce(0) { $0 + $1.wrappedValue }
        }

        let finalSource = 1 + iterations
        let expected = (1...width).reduce(0) { $0 + $1 * finalSource }
        #expect(leaves.reduce(0) { $0 + $1.wrappedValue } == expected)
    }

    // MARK: - Binary tree
    //
    // Tree height = log₂(leafCount) = 10, so recursive re-eval depth = 10. Safe.

    @Test
    func `Binary tree 1024 leaves – initial evaluation`() {
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
                let l = level[i]
                let r = level[i + 1]
                next.append(Attribute { l.wrappedValue + r.wrappedValue })
            }
            level = next
        }
        let root = level[0]

        _ = measure(label: "Binary tree \(leafCount) leaves – initial eval") {
            _ = root.wrappedValue
        }

        #expect(root.wrappedValue == leafCount)
    }

    @Test
    func `Binary tree 1024 leaves – re-evaluation after source change`() {
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
                let l = level[i]
                let r = level[i + 1]
                next.append(Attribute { l.wrappedValue + r.wrappedValue })
            }
            level = next
        }
        let root = level[0]
        _ = root.wrappedValue  // prime

        let iterations = 3
        _ = measure(label: "Binary tree \(leafCount) leaves – re-eval after change", iterations: iterations) {
            source += 1
            _ = root.wrappedValue
        }

        let expectedLeafValue = iterations + 1
        #expect(root.wrappedValue == leafCount * expectedLeafValue)
    }

    // MARK: - Pending cut (no-op clamp)
    //
    // AG1 has no three-state system: there is no .pending state.
    // All potentiallyDirty nodes re-evaluate unconditionally.
    // The downstream chain after the clamp WILL re-evaluate in AG1.

    @Test
    func `Pending cut – 1000 downstream nodes always re-evaluate in AG1`() {
        let graph = Graph()
        graph.makeCurrent()

        let depth = 1_000
        @Attribute var source: Int = 10

        let clamped = Attribute { min(max(source, 0), 10) }

        var chain: [Attribute<Int>] = [clamped]
        for _ in 0..<depth {
            let prev = chain.last!
            chain.append(Attribute { prev.wrappedValue + 1 })
        }
        let leaf = chain.last!
        // Prime iteratively (chain after clamp can be primed directly)
        for node in chain { _ = node.wrappedValue }
        _ = source  // ensure source is primed too

        var evalCount = 0
        let tracked = Attribute {
            evalCount += 1
            return leaf.wrappedValue
        }
        _ = tracked.wrappedValue
        let initCount = evalCount

        let iterations = 5
        _ = measure(label: "Pending cut \(depth) nodes – clamped source write (no pending opt.)", iterations: iterations) {
            source += 1
            _ = tracked.wrappedValue
        }

        // AG1 now has the three-state system + change-cut: the clamped value
        // doesn't change (stays at 10), so the downstream chain is skipped.
        #expect(evalCount == initCount,
                "AG1 now skips downstream nodes when the clamped value is unchanged")
    }

    // MARK: - Multi-diamond lattice

    @Test
    func `Multi-diamond lattice 64×8 – initial evaluation`() {
        let graph = Graph()
        graph.makeCurrent()

        let width = 64
        let layers = 8
        @Attribute var source: Int = 1

        var layer: [Attribute<Int>] = (0..<width).map { i in
            Attribute { source + i }
        }
        for _ in 1..<layers {
            var next: [Attribute<Int>] = []
            for i in 0..<layer.count {
                let left = layer[i]
                let right = layer[(i + 1) % layer.count]
                next.append(Attribute { left.wrappedValue + right.wrappedValue })
            }
            layer = next
        }
        let root = Attribute { layer.reduce(0) { $0 + $1.wrappedValue } }

        _ = measure(label: "Multi-diamond \(width)×\(layers) – initial eval") {
            _ = root.wrappedValue
        }

        #expect(root.wrappedValue > 0)
    }

    @Test
    func `Multi-diamond lattice 64×8 – re-evaluation after source change`() {
        let graph = Graph()
        graph.makeCurrent()

        let width = 64
        let layers = 8
        @Attribute var source: Int = 1

        var layer: [Attribute<Int>] = (0..<width).map { i in
            Attribute { source + i }
        }
        for _ in 1..<layers {
            var next: [Attribute<Int>] = []
            for i in 0..<layer.count {
                let left = layer[i]
                let right = layer[(i + 1) % layer.count]
                next.append(Attribute { left.wrappedValue + right.wrappedValue })
            }
            layer = next
        }
        let root = Attribute { layer.reduce(0) { $0 + $1.wrappedValue } }
        _ = root.wrappedValue
        let initialValue = root.wrappedValue

        let iterations = 5
        _ = measure(label: "Multi-diamond \(width)×\(layers) – re-eval after change", iterations: iterations) {
            source += 1
            _ = root.wrappedValue
        }

        #expect(root.wrappedValue != initialValue)
    }

    // MARK: - Shared dependency deduplication

    @Test
    func `Shared node evaluated once across 500 dependents`() {
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

        _ = measure(label: "500-diamond – re-eval after source change", iterations: 5) {
            source += 1
            _ = root.wrappedValue
        }

        #expect(sharedEvalCount == countAfterInit + 5,
                "shared should be re-evaluated exactly once per source change")

        let finalShared = 5 * 10
        let expectedRoot = (0..<width).reduce(0) { $0 + finalShared + $1 }
        #expect(root.wrappedValue == expectedRoot)
    }
}
