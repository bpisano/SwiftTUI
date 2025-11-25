import Testing

@testable import AttributeGraph

@Test
@MainActor
func `Continuous dependency capture`() async throws {
    let graph: Graph = .init()
    graph.makeCurrent()

    @Attribute var condition = true
    @Attribute var x = 10
    @Attribute var y = 20
    @Attribute var z = 30

    // Conditional dependency: switches between x and y based on condition
    @Attribute var result: Int = condition ? x : y
    @Attribute var final = result + z

    $condition.label = "Condition"
    $x.label = "X"
    $y.label = "Y"
    $z.label = "Z"
    $result.label = "Result"
    $final.label = "Final"

    // Initial evaluation: result depends on condition and x
    #expect(result == 10)
    #expect(final == 40)

    // Verify initial dependencies: result should have edges from condition and x
    #expect($result.incomingEdges.count == 2)
    #expect($result.incomingEdges.contains { $0.from.ref.label == "Condition" })
    #expect($result.incomingEdges.contains { $0.from.ref.label == "X" })
    #expect(!$result.incomingEdges.contains { $0.from.ref.label == "Y" })

    // Change condition to false: dependencies should shift from x to y
    condition = false
    #expect(result == 20)
    #expect(final == 50)

    // After re-evaluation, result should now depend on condition and y (not x)
    #expect($result.incomingEdges.count == 2)
    #expect($result.incomingEdges.contains { $0.from.ref.label == "Condition" })
    #expect($result.incomingEdges.contains { $0.from.ref.label == "Y" })
    #expect(!$result.incomingEdges.contains { $0.from.ref.label == "X" })

    // Change x: should NOT affect result since dependency shifted to y
    x = 999
    #expect(result == 20)  // Still 20, not affected by x
    #expect(final == 50)  // Still 50

    // Dependencies should remain the same (condition and y)
    #expect($result.incomingEdges.count == 2)
    #expect($result.incomingEdges.contains { $0.from.ref.label == "Condition" })
    #expect($result.incomingEdges.contains { $0.from.ref.label == "Y" })

    // Change y: SHOULD affect result since it now depends on y
    y = 100
    #expect(result == 100)
    #expect(final == 130)

    // Switch condition back to true: dependencies shift back to x
    condition = true
    #expect(result == 999)  // Now uses x again
    #expect(final == 1029)

    // Verify dependencies shifted back to x
    #expect($result.incomingEdges.count == 2)
    #expect($result.incomingEdges.contains { $0.from.ref.label == "Condition" })
    #expect($result.incomingEdges.contains { $0.from.ref.label == "X" })
    #expect(!$result.incomingEdges.contains { $0.from.ref.label == "Y" })
}

@Test
@MainActor
func `Dependency evaluation`() async throws {
    let graph: Graph = .init()
    graph.makeCurrent()

    @Attribute var a = 1
    @Attribute var b = 2
    @Attribute var c = a + b
    @Attribute var d = c + 1

    $a.label = "A"
    $b.label = "B"
    $c.label = "C"
    $d.label = "D"

    // Initial evaluation
    #expect(d == 4)
    #expect(c == 3)

    // Verify initial graph structure
    #expect($c.incomingEdges.count == 2)
    #expect($c.incomingEdges.contains { $0.from.ref.label == "A" })
    #expect($c.incomingEdges.contains { $0.from.ref.label == "B" })
    #expect($d.incomingEdges.count == 1)
    #expect($d.incomingEdges.contains { $0.from.ref.label == "C" })

    // Changing values
    a = 3

    // Re-evaluate and verify new values
    #expect(c == 5)
    #expect(d == 6)

    // Change 'a' back
    a = 1

    // Re-evaluate and verify original values
    #expect(c == 3)
    #expect(d == 4)

    // Dependencies should remain stable
    #expect($c.incomingEdges.count == 2)
    #expect($d.incomingEdges.count == 1)
}
