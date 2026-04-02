import Foundation
import Testing

@testable import AttributeGraph2

@Suite("Three-state dirty system")
@MainActor
struct ThreeStateTests {

    // MARK: - State propagation at write time

    @Test
    func `Direct dependent becomes dirty after write`() {
        let graph = Graph()
        graph.makeCurrent()

        @Attribute var source: Int = 1
        let dep = Attribute("dep") { source * 2 }

        _ = dep.wrappedValue
        #expect(dep.wrappedValue == 2)
        #expect($source.state == .clean)
        #expect(dep.state == .clean)

        source = 2

        #expect(dep.state == .dirty)
    }

    @Test
    func `Transitive dependent becomes pending after write`() {
        let graph = Graph()
        graph.makeCurrent()

        @Attribute var source: Int = 1
        let mid = Attribute("mid") { source + 10 }
        let transitive = Attribute("transitive") { mid.wrappedValue * 2 }

        _ = transitive.wrappedValue

        source = 2

        #expect(mid.state == .dirty, "Direct dependent should be .dirty")
        #expect(transitive.state == .pending, "Transitive dependent should be .pending")
    }

    @Test
    func `Two-hop transitive dependent is pending not dirty`() {
        let graph = Graph()
        graph.makeCurrent()

        @Attribute var source: Int = 0
        let hop1 = Attribute("hop1") { source + 1 }
        let hop2 = Attribute("hop2") { hop1.wrappedValue + 1 }
        let hop3 = Attribute("hop3") { hop2.wrappedValue + 1 }

        _ = hop3.wrappedValue

        source = 10

        #expect(hop1.state == .dirty)
        #expect(hop2.state == .pending)
        #expect(hop3.state == .pending)
    }

    @Test
    func `Dirty is not downgraded to pending when node is both direct and transitive dependent`() {
        let graph = Graph()
        graph.makeCurrent()

        // a → b → d
        // a → d  (also a direct dep)
        //
        // When a changes: b becomes .dirty, d should stay .dirty (direct dep wins)
        @Attribute var a: Int = 0
        let b = Attribute("b") { a + 1 }
        // d depends directly on both a and b
        let d = Attribute("d") { a + b.wrappedValue }

        _ = d.wrappedValue

        a = 5

        // d is a direct dependent of a → .dirty
        // BFS from b would try to set d to .pending, but d is already .dirty
        #expect(d.state == .dirty, "Direct dependency should not be downgraded")
    }

    // MARK: - Pending optimization during evaluation

    @Test
    func `Pending node is skipped when direct dep value unchanged`() {
        let graph = Graph()
        graph.makeCurrent()

        var pendingEvalCount = 0

        @Attribute var source: Int = 5
        // mid reads source but always returns 42
        let mid = Attribute("mid") { _ = source; return 42 }
        let pending = Attribute("pending") {
            pendingEvalCount += 1
            return mid.wrappedValue + 1
        }

        _ = pending.wrappedValue
        let countAfterInit = pendingEvalCount

        // source changes → mid is .dirty, pending is .pending
        // mid evaluates to 42 (same as before) → pending should be skipped
        source = 99
        _ = pending.wrappedValue

        #expect(pendingEvalCount == countAfterInit,
                "Pending node should be skipped when its direct dep value did not change")
    }

    @Test
    func `Pending node re-evaluates when direct dep value changed`() {
        let graph = Graph()
        graph.makeCurrent()

        var pendingEvalCount = 0

        @Attribute var source: Int = 5
        let mid = Attribute("mid") { source + 1 }
        let pending = Attribute("pending") {
            pendingEvalCount += 1
            return mid.wrappedValue * 2
        }

        _ = pending.wrappedValue
        let countAfterInit = pendingEvalCount

        source = 10
        _ = pending.wrappedValue

        #expect(pendingEvalCount == countAfterInit + 1,
                "Pending node should re-evaluate when direct dep changed")
        #expect(pending.wrappedValue == (10 + 1) * 2)
    }

    @Test
    func `Pending node is cleaned without re-evaluation when entire chain produces same value`() {
        let graph = Graph()
        graph.makeCurrent()

        var evalA = 0
        var evalB = 0
        var evalC = 0

        @Attribute var source: Int = 10  // Start at the clamp boundary
        // source = 10 → a = min(max(10, 0), 10) = 10, b = 20, c = 120
        // source = 50 → a = min(max(50, 0), 10) = 10 (same!) → b and c should be skipped
        // a: clamps source to 0...10
        let a = Attribute("a") {
            evalA += 1
            return min(max(source, 0), 10)
        }
        // b: depends on a
        let b = Attribute("b") {
            evalB += 1
            return a.wrappedValue * 2
        }
        // c: depends on b (two hops from source)
        let c = Attribute("c") {
            evalC += 1
            return b.wrappedValue + 100
        }

        _ = c.wrappedValue
        let (initA, initB, initC) = (evalA, evalB, evalC)

        // source = 10 → a = 10, b = 20, c = 120 (baseline)
        // source = 50 → a = min(max(50, 0), 10) = 10 (unchanged!) → b and c should be skipped
        source = 50
        _ = c.wrappedValue

        #expect(evalA == initA + 1, "a (dirty) should re-evaluate")
        #expect(evalB == initB, "b (pending, a unchanged) should be skipped")
        #expect(evalC == initC, "c (pending, b unchanged) should be skipped")
    }

    // MARK: - State after evaluation

    @Test
    func `All nodes are clean after evaluation`() {
        let graph = Graph()
        graph.makeCurrent()

        @Attribute var source: Int = 1
        let mid = Attribute("mid") { source + 10 }
        let leaf = Attribute("leaf") { mid.wrappedValue * 2 }

        _ = leaf.wrappedValue

        source = 2
        _ = leaf.wrappedValue

        #expect($source.state == .clean)
        #expect(mid.state == .clean)
        #expect(leaf.state == .clean)
    }
}
