// Reproduction tests for:
// ForEach items cached across re-evaluations retain their original `currentIndex`,
// causing them to read the wrong `childGeometries` slot when a preceding ForEach grows.

import Foundation
import Testing
import Geometry
@testable import AttributeGraph
@testable import SwiftTUICore

@Suite("LayoutBug")
@MainActor
struct LayoutBugTests {
    // Reproduces the chess project bug:
    // - VStack has: static Text, ForEach1 (grows), static Text, ForEach2 (stable)
    // - ForEach2 items are cached from the initial render with old currentIndex values
    // - After ForEach1 grows, ForEach2 items read the wrong childGeometries slot
    //   → rendered at the wrong position (overlaps ForEach1's last item)
    @Test
    func `ForEach2 items use stale index after ForEach1 grows`() async throws {
        @Attribute var items1: [String] = []
        @Attribute var items2: [String] = ["X"]

        @Attribute var view = RootLayout {
            VStack(alignment: .leading, spacing: 0) {
                Text("Header")
                ForEach(items1, id: \.self) { item in
                    Text(item)
                }
                Text("Section 2")
                ForEach(items2, id: \.self) { item in
                    Text(item)
                }
            }
        }

        let size = Size(width: 20, height: 9)
        @Attribute var screenPosition: Point = .zero
        @Attribute var screenSize: Size = size
        @Attribute var viewPhase: ViewPhase = .active
        let inputs = ViewInputs(
            position: $screenPosition,
            size: $screenSize,
            phase: $viewPhase,
            storage: .init()
        )

        let outputs = type(of: view).makeView($view, inputs: inputs)

        // Initial: items1=[], items2=["X"]
        // VStack children: Header(6), Section2(9), X(1) → maxWidth=9, h=3
        // RootLayout 20×9: x=(20-9)/2=5, y=(9-3)/2=3
        await expectDisplayList(outputs.displayList, in: size) {
            """
            ....................
            ....................
            ....................
            .....Header.........
            .....Section 2......
            .....X..............
            ....................
            ....................
            ....................
            """
        }

        // Add two items to ForEach1. ForEach2's "X" item is cached from the initial
        // render with currentIndex=2 (Section2 slot). After this update, Section2 moves
        // to index 3 and X should be at index 4, but the cache still points at index 2.
        items1 = ["A", "B"]

        // VStack children: Header(6), A(1), B(1), Section2(9), X(1) → maxWidth=9, h=5
        // RootLayout 20×9: x=5, y=(9-5)/2=2
        // CORRECT expected:
        await expectDisplayList(outputs.displayList, in: size) {
            """
            ....................
            ....................
            .....Header.........
            .....A..............
            .....B..............
            .....Section 2......
            .....X..............
            ....................
            ....................
            """
        }
    }
}
