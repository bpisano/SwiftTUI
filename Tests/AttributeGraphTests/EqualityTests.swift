//
//  EqualityTests.swift
//  AttributeGraphTests
//

import Foundation
import Testing

@testable import AttributeGraph

@MainActor
@Suite("Equality")
struct EqualityTests {

    // MARK: - Setter short-circuit

    @Test
    func `Setting same value does not trigger onInvalidate`() {
        let graph = Graph()
        graph.makeCurrent()

        var invalidateCount = 0
        graph.onInvalidate = { invalidateCount += 1 }

        @Attribute var count: Int = 0
        _ = count

        count = 0
        #expect(invalidateCount == 0)
    }

    @Test
    func `Setting different value does trigger onInvalidate`() {
        let graph = Graph()
        graph.makeCurrent()

        var invalidateCount = 0
        graph.onInvalidate = { invalidateCount += 1 }

        @Attribute var count: Int = 0
        _ = count

        count = 1
        #expect(invalidateCount == 1)
    }

    @Test
    func `Setting same value does not re-evaluate dependents`() {
        let graph = Graph()
        graph.makeCurrent()

        var evalCount = 0

        @Attribute var source: Int = 5
        let doubled = Attribute("doubled") {
            evalCount += 1
            return source * 2
        }

        _ = doubled.wrappedValue
        let countAfterInit = evalCount

        source = 5
        _ = doubled.wrappedValue

        #expect(evalCount == countAfterInit, "No re-evaluation expected when value is unchanged")
    }

    @Test
    func `Setting different value re-evaluates dependents`() {
        let graph = Graph()
        graph.makeCurrent()

        var evalCount = 0

        @Attribute var source: Int = 5
        let doubled = Attribute("doubled") {
            evalCount += 1
            return source * 2
        }

        _ = doubled.wrappedValue
        let countAfterInit = evalCount

        source = 10
        _ = doubled.wrappedValue

        #expect(evalCount == countAfterInit + 1, "Dependent should re-evaluate after source change")
        #expect(doubled.wrappedValue == 20)
    }

    // MARK: - Change cut after rule evaluation

    @Test
    func `Change cut: dependent skipped when rule returns same value`() {
        let graph = Graph()
        graph.makeCurrent()

        var leafEvalCount = 0

        @Attribute var toggle: Bool = true
        // text always returns the same string regardless of toggle
        let text = Attribute { toggle ? "hello" : "hello" }
        let leaf = Attribute("leaf") {
            leafEvalCount += 1
            return text.wrappedValue.uppercased()
        }

        _ = leaf.wrappedValue
        let countAfterInit = leafEvalCount

        // toggle changes → text is .dirty → evaluates to "hello" again (same value)
        // → leaf should be skipped (change cut)
        toggle = false
        _ = leaf.wrappedValue

        #expect(leafEvalCount == countAfterInit, "Leaf should be skipped: text value did not change")
    }

    @Test
    func `Change cut stops at equality boundary in deep chain`() {
        let graph = Graph()
        graph.makeCurrent()

        var deepEvalCount = 0

        @Attribute var source: Int = 1
        // mid always clamps to 0...10
        let mid = Attribute { min(max(source, 0), 10) }
        let deep = Attribute("deep") {
            deepEvalCount += 1
            return mid.wrappedValue * 3
        }

        _ = deep.wrappedValue
        let countAfterInit = deepEvalCount

        // source 1 → 2: mid changes (1→2), deep re-evaluates
        source = 2
        _ = deep.wrappedValue
        #expect(deepEvalCount == countAfterInit + 1)

        // source 2 → 3: mid changes (2→3), deep re-evaluates
        source = 3
        _ = deep.wrappedValue
        #expect(deepEvalCount == countAfterInit + 2)

        // source 3 → 10: mid changes (3→10), deep re-evaluates
        source = 10
        _ = deep.wrappedValue
        #expect(deepEvalCount == countAfterInit + 3)

        // source 10 → 15: mid still clamps to 10 (unchanged) → deep skipped
        source = 15
        _ = deep.wrappedValue
        #expect(deepEvalCount == countAfterInit + 3, "Deep should be skipped: mid clamped to same value")
    }

    // MARK: - Non-equatable types do not short-circuit

    @Test
    func `Non-equatable type always propagates`() {
        let graph = Graph()
        graph.makeCurrent()

        var evalCount = 0

        struct NonEquatable { let value: Int }

        let source = Attribute(rule: ValueRule { NonEquatable(value: 0) })
        let dep = Attribute("dep", rule: ComputedRule {
            evalCount += 1
            _ = source.wrappedValue
            return 0
        })

        _ = dep.wrappedValue
        let countAfterInit = evalCount

        source.wrappedValue = NonEquatable(value: 0)
        _ = dep.wrappedValue

        #expect(evalCount == countAfterInit + 1, "Non-equatable type should always propagate")
    }
}
