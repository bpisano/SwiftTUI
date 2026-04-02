import Foundation
import Testing

@testable import AttributeGraph2

// MARK: - Measurement helper

/// Runs `operation` `iterations` times, prints average elapsed time, and returns it.
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
    print("  ⏱  \(label)\(suffix): \(String(format: "%.3f", ms)) ms")
    return avg
}

// MARK: - Tests

@Suite("Performance benchmarks")
@MainActor
struct PerformanceBenchmarkTests {

    // MARK: - Deep linear chain

    /// source → n₁ → n₂ → … → n_depth   (each node adds 1)
    ///
    /// Initial evaluation IS recursive (no edges exist yet to traverse iteratively).
    /// We prime iteratively by keeping all intermediate nodes and evaluating
    /// source→leaf in order — each step is O(1) since its predecessor is already clean.

    @Test
    func `Deep chain 5000 – initial evaluation`() {
        let graph = Graph()
        graph.makeCurrent()

        let depth = 5_000
        @Attribute var source: Int = 0

        // Build chain and keep all nodes so we can prime iteratively.
        var chain: [Attribute<Int>] = [$source]
        for _ in 0..<depth {
            let prev = chain.last!
            chain.append(Attribute { prev.wrappedValue + 1 })
        }
        let leaf = chain.last!

        _ = measure(label: "Deep chain \(depth) – initial eval (iterative priming)") {
            // Evaluate from source outward: each read is O(1) since its predecessor is already clean.
            for node in chain { _ = node.wrappedValue }
        }

        #expect(leaf.wrappedValue == depth, "Each node adds 1, so leaf should equal depth")
    }

    @Test
    func `Deep chain 5000 – re-evaluation after source change`() {
        let graph = Graph()
        graph.makeCurrent()

        let depth = 5_000
        @Attribute var source: Int = 0

        var chain: [Attribute<Int>] = [$source]
        for _ in 0..<depth {
            let prev = chain.last!
            chain.append(Attribute { prev.wrappedValue + 1 })
        }
        let leaf = chain.last!
        for node in chain { _ = node.wrappedValue }  // prime iteratively

        let iterations = 5
        _ = measure(label: "Deep chain \(depth) – re-eval after change (iterative DFS)", iterations: iterations) {
            source += 1
            _ = leaf.wrappedValue
        }

        // After `iterations` increments source == iterations → leaf == iterations + depth
        #expect(leaf.wrappedValue == iterations + depth)
    }

    @Test
    func `Deep chain 5000 – no-op re-evaluation (equality short-circuit)`() {
        let graph = Graph()
        graph.makeCurrent()

        let depth = 5_000
        @Attribute var source: Int = 0

        var chain: [Attribute<Int>] = [$source]
        for _ in 0..<depth {
            let prev = chain.last!
            chain.append(Attribute { prev.wrappedValue + 1 })
        }
        let leaf = chain.last!
        for node in chain { _ = node.wrappedValue }  // prime iteratively

        var evalCount = 0
        let tracked = Attribute {
            evalCount += 1
            return leaf.wrappedValue
        }
        _ = tracked.wrappedValue
        let initCount = evalCount

        _ = measure(label: "Deep chain \(depth) – no-op (same value, short-circuit)", iterations: 5) {
            source = 0   // same value every time → equality short-circuit fires immediately
            _ = tracked.wrappedValue
        }

        // The entire downstream chain must have been skipped
        #expect(evalCount == initCount, "No node should re-evaluate when source value is unchanged")
    }

    // MARK: - Wide fan-out

    /// source → leaf₀, leaf₁, …, leaf₄₉₉₉   (each leaf = source × (i+1))
    ///
    /// Tests propagation to a very wide set of direct dependents.

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

        // sum = 1×1 + 1×2 + … + 1×5000 = 5000×5001/2
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

        // After `iterations` increments source == 1 + iterations
        let finalSource = 1 + iterations
        let expected = (1...width).reduce(0) { $0 + $1 * finalSource }
        #expect(leaves.reduce(0) { $0 + $1.wrappedValue } == expected)
    }

    // MARK: - Binary tree (reduce pattern)

    /// 4096 leaves → 2048 pairs → … → 1 root   (12 levels, 8191 total nodes)
    ///
    /// Each leaf = source + 1. Tests evaluation of a balanced tree where
    /// a source change forces re-evaluation of every node.

    @Test
    func `Binary tree 4096 leaves – initial evaluation`() {
        let graph = Graph()
        graph.makeCurrent()

        let leafCount = 1 << 12  // 4096
        @Attribute var source: Int = 0

        // Build leaves: each leaf = source + 1 (so leaf value = 1 when source = 0)
        var level: [Attribute<Int>] = (0..<leafCount).map { _ in
            Attribute { source + 1 }
        }

        // Reduce bottom-up: each parent = left + right
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

        // All leaves = 1 → root = 4096
        #expect(root.wrappedValue == leafCount)
    }

    @Test
    func `Binary tree 4096 leaves – re-evaluation after source change`() {
        let graph = Graph()
        graph.makeCurrent()

        let leafCount = 1 << 12  // 4096
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

        // source = iterations → each leaf = iterations + 1 → root = leafCount × (iterations + 1)
        let expectedLeafValue = iterations + 1
        #expect(root.wrappedValue == leafCount * expectedLeafValue)
    }

    // MARK: - Pending optimization (change-cut) at scale

    /// source → clamp(source, 0…10) → n₁ → n₂ → … → n₁₀₀₀
    ///
    /// When source goes from 10 to 100, the clamped node stays at 10.
    /// The change-cut must prevent the entire 1000-node downstream chain
    /// from re-evaluating.

    @Test
    func `Pending cut – 1000 downstream nodes skipped after no-op clamp`() {
        let graph = Graph()
        graph.makeCurrent()

        let depth = 1_000
        @Attribute var source: Int = 10  // already at the clamp boundary

        let clamped = Attribute { min(max(source, 0), 10) }

        var previous = clamped
        for _ in 0..<depth {
            let prev = previous
            previous = Attribute { prev.wrappedValue + 1 }
        }
        let leaf = previous
        _ = leaf.wrappedValue  // prime

        // Track how often the leaf node re-evaluates
        var leafEvalCount = 0
        let tracked = Attribute {
            leafEvalCount += 1
            return leaf.wrappedValue
        }
        _ = tracked.wrappedValue
        let initCount = leafEvalCount

        let iterations = 5
        _ = measure(label: "Pending cut \(depth) nodes – clamped source write", iterations: iterations) {
            source += 1   // clamp(11+, 0…10) == 10 → downstream unchanged
            _ = tracked.wrappedValue
        }

        #expect(leafEvalCount == initCount, "No downstream node should re-evaluate: clamped value is unchanged")
        #expect(tracked.wrappedValue == 10 + depth, "Leaf value should remain at the clamped baseline")
    }

    // MARK: - Multi-diamond (many shared nodes)

    /// 8-layer lattice of width 64, where each layer-k node = layer[k-1][i] + layer[k-1][(i+1)%64].
    ///
    /// Total nodes: 8 × 64 = 512 (plus a root sum).
    /// Every node at every layer depends on two neighbours in the previous layer,
    /// producing a dense web of shared-dependency paths.

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

        #expect(root.wrappedValue > 0, "Root should have a non-zero computed value")
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
        _ = root.wrappedValue  // prime
        let initialValue = root.wrappedValue

        let iterations = 5
        _ = measure(label: "Multi-diamond \(width)×\(layers) – re-eval after change", iterations: iterations) {
            source += 1
            _ = root.wrappedValue
        }

        // Root must change: source drives all layer-0 nodes
        #expect(root.wrappedValue != initialValue, "Root must change when source changes")
    }

    // MARK: - Shared dependency deduplication at scale

    /// One shared node sits in the middle of a diamond of width 500:
    ///   source → shared → leaf₀, leaf₁, …, leaf₄₉₉
    ///   root = Σ(leafᵢ)
    ///
    /// When source changes, `shared` must be evaluated exactly once
    /// despite 500 paths leading to it.

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

        // shared must have been re-evaluated exactly once per outer iteration (5 times total)
        #expect(sharedEvalCount == countAfterInit + 5,
                "shared should be re-evaluated exactly once per source change, not once per dependent")

        // Correctness: source=5, shared=50, root = Σ(50+i) for i in 0..<500 = 500×50 + (0+499)×500/2
        let finalShared = 5 * 10
        let expectedRoot = (0..<width).reduce(0) { $0 + finalShared + $1 }
        #expect(root.wrappedValue == expectedRoot)
    }
}
