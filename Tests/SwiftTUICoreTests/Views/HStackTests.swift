//
//  HStackTests.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 21/03/2026.
//

import Foundation
import Geometry
import Testing

@testable import AttributeGraph
@testable import SwiftTUICore

@Suite("HStack")
@MainActor
struct HStackTests {
    // MARK: - Basic Layout Tests

    @Test
    func `Two Text Views - No Spacing`() async throws {
        expectView(in: Size(width: 10, height: 3)) {
            HStack {
                Text("Alice")
                Text("Bob")
            }
        } toRender: {
            """
            AliceBob..
            ..........
            ..........
            """
        }
    }

    @Test
    func `Three Text Views - No Spacing`() async throws {
        expectView(in: Size(width: 10, height: 4)) {
            HStack {
                Text("A")
                Text("BB")
                Text("CCC")
            }
        } toRender: {
            """
            ABBCCC....
            ..........
            ..........
            ..........
            """
        }
    }

    // MARK: - Spacing Tests

    @Test
    func `Two Text Views - With Spacing`() async throws {
        expectView(in: Size(width: 10, height: 3)) {
            HStack(spacing: 1) {
                Text("Alice")
                Text("Bob")
            }
        } toRender: {
            """
            Alice.Bob.
            ..........
            ..........
            """
        }
    }

    @Test
    func `Three Text Views - With Spacing`() async throws {
        expectView(in: Size(width: 10, height: 4)) {
            HStack(spacing: 2) {
                Text("A")
                Text("B")
                Text("C")
            }
        } toRender: {
            """
            A..B..C...
            ..........
            ..........
            ..........
            """
        }
    }

    // MARK: - Alignment Tests

    @Test
    func `Top Alignment`() async throws {
        expectView(in: Size(width: 5, height: 6)) {
            HStack(alignment: .top) {
                Text("A")
                Text("BBB")
                    .frame(width: 1)
                Text("CCCCC")
                    .frame(width: 1)
            }
        } toRender: {
            """
            ABC..
            .BC..
            .BC..
            ..C..
            ..C..
            .....
            """
        }
    }

    @Test
    func `Center Alignment (Default)`() async throws {
        expectView(in: Size(width: 5, height: 6)) {
            HStack {
                Text("A")
                Text("BBB")
                    .frame(width: 1)
                Text("CCCCC")
                    .frame(width: 1)
            }
        } toRender: {
            """
            ..C..
            .BC..
            ABC..
            .BC..
            ..C..
            .....
            """
        }
    }

    @Test
    func `Bottom Alignment`() async throws {
        expectView(in: Size(width: 5, height: 6)) {
            HStack(alignment: .bottom) {
                Text("A")
                Text("BBB")
                    .frame(width: 1)
                Text("CCCCC")
                    .frame(width: 1)
            }
        } toRender: {
            """
            ..C..
            ..C..
            .BC..
            .BC..
            ABC..
            .....
            """
        }
    }

    // MARK: - Flexible View Tests

    @Test
    func `Single Expanding View`() async throws {
        expectView(in: Size(width: 5, height: 5)) {
            HStack {
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
            HStack {
                Text("Hi")
                ExpandingView(char: "X")
            }
        } toRender: {
            """
            ..XXX
            ..XXX
            HiXXX
            ..XXX
            ..XXX
            """
        }
    }

    @Test
    func `Expanding View and Text`() async throws {
        expectView(in: Size(width: 5, height: 5)) {
            HStack {
                ExpandingView(char: "X")
                Text("Hi")
            }
        } toRender: {
            """
            XXX..
            XXX..
            XXXHi
            XXX..
            XXX..
            """
        }
    }

    @Test
    func `Text, Expanding View, Text`() async throws {
        expectView(in: Size(width: 10, height: 5)) {
            HStack {
                Text("Top")
                ExpandingView(char: "X")
                Text("End")
            }
        } toRender: {
            """
            ...XXXX...
            ...XXXX...
            TopXXXXEnd
            ...XXXX...
            ...XXXX...
            """
        }
    }

    @Test
    func `Two Expanding Views Split Space`() async throws {
        expectView(in: Size(width: 6, height: 4)) {
            HStack {
                ExpandingView(char: "A")
                ExpandingView(char: "B")
            }
        } toRender: {
            """
            AAABBB
            AAABBB
            AAABBB
            AAABBB
            """
        }
    }

    @Test
    func `Expanding Views with Spacing`() async throws {
        expectView(in: Size(width: 7, height: 4)) {
            HStack(spacing: 1) {
                ExpandingView(char: "A")
                ExpandingView(char: "B")
            }
        } toRender: {
            """
            AAA.BBB
            AAA.BBB
            AAA.BBB
            AAA.BBB
            """
        }
    }

    @Test
    func `Expanding View with Center Alignment`() async throws {
        expectView(in: Size(width: 10, height: 3)) {
            HStack {
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
    func `Mixed Views with Bottom Alignment`() async throws {
        expectView(in: Size(width: 10, height: 4)) {
            HStack(alignment: .bottom, spacing: 1) {
                Text("A")
                ExpandingView(char: "X")
                Text("BB")
                    .frame(width: 1)
            }
        } toRender: {
            """
            ..XXXXXX..
            ..XXXXXX..
            ..XXXXXX.B
            A.XXXXXX.B
            """
        }
    }

    @Test
    func `Nested HStack`() {
        expectView(in: Size(width: 8, height: 5)) {
            RootLayout {
                HStack {
                    Text("A")

                    HStack(spacing: 1) {
                        Text("B")
                        Text("C")
                    }
                }
            }
        } toRender: {
            """
            ........
            ........
            ..AB.C..
            ........
            ........
            """
        }
    }
}
