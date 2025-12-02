import Testing

@testable import AttributeGraph

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
