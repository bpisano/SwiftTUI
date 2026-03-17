//
//  VStackTests.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 15/03/2026.
//

import Foundation
import Geometry
import Testing

@testable import AttributeGraph
@testable import SwiftTUICore

@Suite("VStack")
struct VStackTests {
    // MARK: - Basic Layout Tests

    @Test("Two Text Views - No Spacing")
    func twoTextsNoSpacing() async throws {
        expectView(in: Size(width: 10, height: 3)) {
            VStack {
                Text("Alice")
                Text("Bob")
            }
        } toRender: {
            """
            Alice.....
            .Bob......
            ..........
            """
        }
    }

    @Test("Three Text Views - No Spacing")
    func threeTextsNoSpacing() async throws {
        expectView(in: Size(width: 10, height: 4)) {
            VStack {
                Text("A")
                Text("BB")
                Text("CCC")
            }
        } toRender: {
            """
            .A........
            BB........
            CCC.......
            ..........
            """
        }
    }

    // MARK: - Spacing Tests

    @Test("Two Text Views - With Spacing")
    func twoTextsWithSpacing() async throws {
        expectView(in: Size(width: 10, height: 5)) {
            VStack(spacing: 1) {
                Text("Alice")
                Text("Bob")
            }
        } toRender: {
            """
            Alice.....
            ..........
            .Bob......
            ..........
            ..........
            """
        }
    }

    @Test("Three Text Views - With Spacing")
    func threeTextsWithSpacing() async throws {
        expectView(in: Size(width: 6, height: 10)) {
            VStack(spacing: 2) {
                Text("A")
                Text("B")
                Text("C")
            }
        } toRender: {
            """
            A.....
            ......
            ......
            B.....
            ......
            ......
            C.....
            ......
            ......
            ......
            """
        }
    }

    // MARK: - Alignment Tests

    @Test("Leading Alignment")
    func leadingAlignment() async throws {
        expectView(in: Size(width: 10, height: 4)) {
            VStack(alignment: .leading) {
                Text("A")
                Text("BB")
                Text("CCC")
            }
        } toRender: {
            """
            A.........
            BB........
            CCC.......
            ..........
            """
        }
    }

    @Test("Center Alignment (Default)")
    func centerAlignment() async throws {
        expectView(in: Size(width: 10, height: 4)) {
            VStack {
                Text("A")
                Text("BB")
                Text("CCC")
            }
        } toRender: {
            """
            .A........
            BB........
            CCC.......
            ..........
            """
        }
    }

    @Test("Trailing Alignment")
    func trailingAlignment() async throws {
        expectView(in: Size(width: 10, height: 4)) {
            VStack(alignment: .trailing) {
                Text("A")
                Text("BB")
                Text("CCC")
            }
        } toRender: {
            """
            ..A.......
            .BB.......
            CCC.......
            ..........
            """
        }
    }

    @Test("Center Alignment with Spacing")
    func centerAlignmentWithSpacing() async throws {
        expectView(in: Size(width: 10, height: 5)) {
            VStack(spacing: 1) {
                Text("A")
                Text("BB")
            }
        } toRender: {
            """
            A.........
            ..........
            BB........
            ..........
            ..........
            """
        }
    }

    // MARK: - Flexible View Tests

    @Test("Single Expanding View")
    func singleExpandingView() async throws {
        expectView(in: Size(width: 5, height: 5)) {
            VStack {
                ExpandingView(char: "X")
            }
        } toRender: {
            """
            XXXXX
            XXXXX
            XXXXX
            XXXXX
            XXXXX
            """
        }
    }

    @Test("Text and Expanding View")
    func textAndExpandingView() async throws {
        expectView(in: Size(width: 5, height: 5)) {
            VStack {
                Text("Hi")
                ExpandingView(char: "X")
            }
        } toRender: {
            """
            .Hi..
            XXXXX
            XXXXX
            XXXXX
            XXXXX
            """
        }
    }

    @Test("Expanding View and Text")
    func expandingViewAndText() async throws {
        expectView(in: Size(width: 5, height: 5)) {
            VStack {
                ExpandingView(char: "X")
                Text("Hi")
            }
        } toRender: {
            """
            XXXXX
            XXXXX
            XXXXX
            XXXXX
            .Hi..
            """
        }
    }

    @Test("Text, Expanding View, Text")
    func textExpandingViewText() async throws {
        expectView(in: Size(width: 6, height: 6)) {
            VStack {
                Text("Top")
                ExpandingView(char: "X")
                Text("Bottom")
            }
        } toRender: {
            """
            .Top..
            XXXXXX
            XXXXXX
            XXXXXX
            XXXXXX
            Bottom
            """
        }
    }

    @Test("Two Expanding Views Split Space")
    func twoExpandingViewsSplitSpace() async throws {
        expectView(in: Size(width: 4, height: 6)) {
            VStack {
                ExpandingView(char: "A")
                ExpandingView(char: "B")
            }
        } toRender: {
            """
            AAAA
            AAAA
            AAAA
            BBBB
            BBBB
            BBBB
            """
        }
    }

    @Test("Expanding Views with Spacing")
    func expandingViewsWithSpacing() async throws {
        expectView(in: Size(width: 4, height: 7)) {
            VStack(spacing: 1) {
                ExpandingView(char: "A")
                ExpandingView(char: "B")
            }
        } toRender: {
            """
            AAAA
            AAAA
            AAAA
            ....
            BBBB
            BBBB
            BBBB
            """
        }
    }

    @Test("Expanding View with Center Alignment")
    func expandingViewWithCenterAlignment() async throws {
        expectView(in: Size(width: 10, height: 3)) {
            VStack {
                ExpandingView(char: "X")
            }
        } toRender: {
            """
            XXXXXXXXXX
            XXXXXXXXXX
            XXXXXXXXXX
            """
        }
    }

    @Test("Mixed Views with Trailing Alignment")
    func mixedViewsWithTrailingAlignment() async throws {
        expectView(in: Size(width: 10, height: 5)) {
            VStack(alignment: .trailing, spacing: 1) {
                Text("A")
                ExpandingView(char: "X")
                Text("BB")
            }
        } toRender: {
            """
            .........A
            ..........
            XXXXXXXXXX
            ..........
            ........BB
            """
        }
    }

    @Test
    func `Nested VStack`() {
        expectView(in: Size(width: 9, height: 5)) {
            RootLayout {
                VStack {
                    Text("Alice")

                    VStack(spacing: 1) {
                        Text("Bob")
                        Text("Charlie")
                    }
                }
            }
        } toRender: {
            """
            ..Alice..
            ...Bob...
            .........
            .Charlie.
            .........
            """
        }
    }
}
