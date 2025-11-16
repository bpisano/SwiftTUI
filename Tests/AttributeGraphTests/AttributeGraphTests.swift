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

    $a.id = "A"
    $b.id = "B"
    $c.id = "C"
    $d.id = "D"

    let d1: String =
    """
    digraph {
        A
        B
        C
        D
        A -> C
        B -> C
        C -> D
    }
    """
    #expect(d == 4)
    #expect(graph.description == d1)

    // Changing values

    a = 3

    let d2: String =
    """
    digraph {
        A
        B
        C [style=dashed]
        D [style=dashed]
        A -> C [style=dashed]
        B -> C
        C -> D
    }
    """
    #expect(graph.description == d2)

    #expect(d == 6)
    #expect(graph.description == d1)

    a = 1

    #expect(graph.description == d2)
    #expect(d == 4)
}
