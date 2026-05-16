//
//  IterativeEvaluationTests.swift
//  AttributeGraphTests
//

import Foundation
import Testing

@testable import AttributeGraph

@MainActor
@Suite("Iterative evaluation")
struct IterativeEvaluationTests {

    // MARK: - Correct evaluation order

    @Test
    func `Dependencies are evaluated before dependents`() {
        let graph = Graph()
        Graph.withCurrent(graph) {

            var order: [String] = []

            @Attribute var a: Int = 1
            let b = Attribute("b") {
                order.append("b")
                return a + 10
            }
            let c = Attribute("c") {
                order.append("c")
                return b.wrappedValue * 2
            }

            _ = c.wrappedValue
            order.removeAll()

            a = 2
            _ = c.wrappedValue

            #expect(order == ["b", "c"])
        }
    }

    @Test
    func `Shared dependency is evaluated only once`() {
        let graph = Graph()
        Graph.withCurrent(graph) {

            var sharedEvalCount = 0

            @Attribute var source: Int = 1
            let shared = Attribute("shared") {
                sharedEvalCount += 1
                return source * 10
            }
            let left = Attribute("left") { shared.wrappedValue + 1 }
            let right = Attribute("right") { shared.wrappedValue + 2 }
            let root = Attribute("root") { left.wrappedValue + right.wrappedValue }

            _ = root.wrappedValue
            let countAfterInit = sharedEvalCount

            source = 2
            _ = root.wrappedValue

            #expect(sharedEvalCount == countAfterInit + 1,
                    "Shared dependency should be evaluated only once despite multiple paths")
        }
    }

    @Test
    func `Diamond dependency: shared node evaluated once`() {
        let graph = Graph()
        Graph.withCurrent(graph) {

            // Classic diamond:
            //       source
            //      /      \
            //    left    right
            //      \      /
            //        sink

            var leftCount = 0
            var rightCount = 0
            var sinkCount = 0

            @Attribute var source: Int = 0
            let left = Attribute("left") {
                leftCount += 1
                return source + 1
            }
            let right = Attribute("right") {
                rightCount += 1
                return source + 2
            }
            let sink = Attribute("sink") {
                sinkCount += 1
                return left.wrappedValue + right.wrappedValue
            }

            _ = sink.wrappedValue
            let (initLeft, initRight, initSink) = (leftCount, rightCount, sinkCount)

            source = 10
            _ = sink.wrappedValue

            #expect(leftCount == initLeft + 1)
            #expect(rightCount == initRight + 1)
            #expect(sinkCount == initSink + 1)
            #expect(sink.wrappedValue == (10 + 1) + (10 + 2))
        }
    }

    // MARK: - Stale edge pruning

    @Test
    func `Stale edges are removed after re-evaluation with different dependencies`() {
        let graph = Graph()
        Graph.withCurrent(graph) {

            @Attribute var useA: Bool = true
            @Attribute var a: Int = 10
            @Attribute var b: Int = 20
            let result = Attribute("result") { useA ? a : b }

            _ = result.wrappedValue
            #expect(result.wrappedValue == 10)

            useA = false
            _ = result.wrappedValue
            #expect(result.wrappedValue == 20)

            // Change a — result should NOT re-evaluate (a is no longer a dependency)
            var evalCount = 0
            let tracked = Attribute("tracked") {
                evalCount += 1
                return result.wrappedValue + 1
            }
            _ = tracked.wrappedValue
            let countAfterInit = evalCount

            a = 99
            _ = tracked.wrappedValue

            #expect(evalCount == countAfterInit,
                    "tracked should not re-evaluate: result no longer depends on a")
        }
    }

    @Test
    func `Previously stale dependency triggers re-evaluation after switching back`() {
        let graph = Graph()
        Graph.withCurrent(graph) {

            @Attribute var useA: Bool = true
            @Attribute var a: Int = 1
            @Attribute var b: Int = 100
            let result = Attribute("result") { useA ? a : b }

            _ = result.wrappedValue
            #expect(result.wrappedValue == 1)

            // Switch to b, then back to a
            useA = false
            _ = result.wrappedValue
            useA = true
            _ = result.wrappedValue

            // Now a is active again; changing a should propagate
            a = 42
            _ = result.wrappedValue
            #expect(result.wrappedValue == 42)
        }
    }

    // MARK: - Correctness on deep chains

    @Test
    func `Deep chain evaluates correctly`() {
        let graph = Graph()
        Graph.withCurrent(graph) {

            let depth = 50
            @Attribute var source: Int = 0

            var previous = $source
            for _ in 0..<depth {
                let prev = previous
                let next = Attribute { prev.wrappedValue + 1 }
                previous = next
            }

            let leaf = previous
            _ = leaf.wrappedValue
            #expect(leaf.wrappedValue == depth)

            source = 10
            #expect(leaf.wrappedValue == 10 + depth)
        }
    }

    @Test
    func `Very deep chain does not overflow the stack`() {
        let graph = Graph()
        Graph.withCurrent(graph) {

            // The original recursive implementation would overflow around depth 500-1000.
            // The iterative implementation handles this without issue.
            let depth = 1000
            @Attribute var source: Int = 0

            var previous = $source
            for _ in 0..<depth {
                let prev = previous
                let next = Attribute { prev.wrappedValue + 1 }
                previous = next
            }

            let leaf = previous
            _ = leaf.wrappedValue
            #expect(leaf.wrappedValue == depth)

            source = 5
            #expect(leaf.wrappedValue == 5 + depth)
        }
    }

    // MARK: - Initial evaluation

    @Test
    func `Initial evaluation triggers rule execution`() {
        let graph = Graph()
        Graph.withCurrent(graph) {

            var evalCount = 0
            let value = Attribute {
                evalCount += 1
                return 42
            }

            #expect(evalCount == 0, "Rule should not be evaluated before first access")
            _ = value.wrappedValue
            #expect(evalCount == 1, "Rule should be evaluated on first access")
            _ = value.wrappedValue
            #expect(evalCount == 1, "Rule should not be re-evaluated if value is cached and clean")
        }
    }

    @Test
    func `Initial computed attribute reads its dependencies correctly`() {
        let graph = Graph()
        Graph.withCurrent(graph) {

            @Attribute var x: Int = 7
            let y = Attribute { x * x }

            #expect(y.wrappedValue == 49)

            x = 3
            #expect(y.wrappedValue == 9)
        }
    }
}
