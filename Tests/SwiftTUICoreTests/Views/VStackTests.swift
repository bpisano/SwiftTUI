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

    @Test
    func `Two Text Views - No Spacing`() async throws {
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

    @Test
    func `Three Text Views - No Spacing`() async throws {
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

    @Test
    func `Two Text Views - With Spacing`() async throws {
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

    @Test
    func `Three Text Views - With Spacing`() async throws {
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

    @Test
    func `Leading Alignment`() async throws {
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

    @Test
    func `Center Alignment (Default)`() async throws {
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

    @Test
    func `Trailing Alignment`() async throws {
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

    @Test
    func `Center Alignment with Spacing`() async throws {
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

    @Test
    func `Single Expanding View`() async throws {
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

    @Test
    func `Text and Expanding View`() async throws {
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

    @Test
    func `Expanding View and Text`() async throws {
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

    @Test
    func `Text, Expanding View, Text`() async throws {
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

    @Test
    func `Two Expanding Views Split Space`() async throws {
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

    @Test
    func `Expanding Views with Spacing`() async throws {
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

    @Test
    func `Expanding View with Center Alignment`() async throws {
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

    @Test
    func `Mixed Views with Trailing Alignment`() async throws {
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
