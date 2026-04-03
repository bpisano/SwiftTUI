//
//  FrameTests.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 16/03/2026.
//

import Foundation
import Geometry
import Testing

@testable import AttributeGraph
@testable import SwiftTUICore

@Suite(".frame")
@MainActor
struct FrameTests {
    // MARK: - Basic Frame Tests

    @Test
    func `Text with Fixed Width`() async throws {
        expectView(in: Size(width: 10, height: 3)) {
            Text("Alice")
                .frame(width: 7)
        } toRender: {
            """
            .Alice....
            ..........
            ..........
            """
        }
    }

    @Test
    func `Text with Fixed Height`() async throws {
        expectView(in: Size(width: 10, height: 3)) {
            Text("Alice")
                .frame(height: 3)
        } toRender: {
            """
            ..........
            Alice.....
            ..........
            """
        }
    }

    @Test
    func `Text with Fixed Width and Height`() async throws {
        expectView(in: Size(width: 10, height: 3)) {
            Text("Alice")
                .frame(width: 7, height: 3)
        } toRender: {
            """
            ..........
            .Alice....
            ..........
            """
        }
    }

    // MARK: - Alignment Tests

    @Test
    func `Top Leading Alignment`() async throws {
        expectView(in: Size(width: 10, height: 3)) {
            Text("Alice")
                .frame(width: 10, height: 3, alignment: .topLeading)
        } toRender: {
            """
            Alice.....
            ..........
            ..........
            """
        }
    }

    @Test
    func `Top Center Alignment`() async throws {
        expectView(in: Size(width: 10, height: 3)) {
            Text("Alice")
                .frame(width: 10, height: 5, alignment: .top)
        } toRender: {
            """
            ..Alice...
            ..........
            ..........
            """
        }
    }

    @Test
    func `Top Trailing Alignment`() async throws {
        expectView(in: Size(width: 10, height: 3)) {
            Text("Alice")
                .frame(width: 10, height: 3, alignment: .topTrailing)
        } toRender: {
            """
            .....Alice
            ..........
            ..........
            """
        }
    }

    @Test
    func `Center Leading Alignment`() async throws {
        expectView(in: Size(width: 10, height: 3)) {
            Text("Alice")
                .frame(width: 10, height: 3, alignment: .leading)
        } toRender: {
            """
            ..........
            Alice.....
            ..........
            """
        }
    }

    @Test
    func `Center Alignment (Default)`() async throws {
        expectView(in: Size(width: 10, height: 3)) {
            Text("Alice")
                .frame(width: 10, height: 3)
        } toRender: {
            """
            ..........
            ..Alice...
            ..........
            """
        }
    }

    @Test
    func `Center Trailing Alignment`() async throws {
        expectView(in: Size(width: 10, height: 3)) {
            Text("Alice")
                .frame(width: 10, height: 3, alignment: .trailing)
        } toRender: {
            """
            ..........
            .....Alice
            ..........
            """
        }
    }

    @Test
    func `Bottom Leading Alignment`() async throws {
        expectView(in: Size(width: 10, height: 3)) {
            Text("Alice")
                .frame(width: 10, height: 3, alignment: .bottomLeading)
        } toRender: {
            """
            ..........
            ..........
            Alice.....
            """
        }
    }

    @Test
    func `Bottom Center Alignment`() async throws {
        expectView(in: Size(width: 10, height: 3)) {
            Text("Alice")
                .frame(width: 10, height: 3, alignment: .bottom)
        } toRender: {
            """
            ..........
            ..........
            ..Alice...
            """
        }
    }

    @Test
    func `Bottom Trailing Alignment`() async throws {
        expectView(in: Size(width: 10, height: 3)) {
            Text("Alice")
                .frame(width: 10, height: 3, alignment: .bottomTrailing)
        } toRender: {
            """
            ..........
            ..........
            .....Alice
            """
        }
    }

    // MARK: - Width Only with Alignment

    @Test
    func `Width Only - Leading`() async throws {
        expectView(in: Size(width: 10, height: 3)) {
            Text("Alice")
                .frame(width: 8, alignment: .leading)
        } toRender: {
            """
            Alice.....
            ..........
            ..........
            """
        }
    }

    @Test
    func `Width Only - Center (Default)`() async throws {
        expectView(in: Size(width: 10, height: 3)) {
            Text("Alice")
                .frame(width: 8)
        } toRender: {
            """
            .Alice....
            ..........
            ..........
            """
        }
    }

    @Test
    func `Width Only - Trailing`() async throws {
        expectView(in: Size(width: 10, height: 3)) {
            Text("Alice")
                .frame(width: 8, alignment: .trailing)
        } toRender: {
            """
            ...Alice..
            ..........
            ..........
            """
        }
    }

    // MARK: - Height Only with Alignment

    @Test
    func `Height Only - Top`() async throws {
        expectView(in: Size(width: 8, height: 3)) {
            Text("Alice")
                .frame(height: 3, alignment: .top)
        } toRender: {
            """
            Alice...
            ........
            ........
            """
        }
    }

    @Test
    func `Height Only - Center (Default)`() async throws {
        expectView(in: Size(width: 8, height: 3)) {
            Text("Alice")
                .frame(height: 3)
        } toRender: {
            """
            ........
            Alice...
            ........
            """
        }
    }

    @Test
    func `Height Only - Bottom`() async throws {
        expectView(in: Size(width: 8, height: 4)) {
            Text("Alice")
                .frame(height: 3, alignment: .bottom)
        } toRender: {
            """
            ........
            ........
            Alice...
            ........
            """
        }
    }

    // MARK: - Expanding View Tests

    @Test
    func `Expanding View with Frame`() async throws {
        expectView(in: Size(width: 10, height: 4)) {
            ExpandingView(char: "X")
                .frame(width: 6, height: 3)
        } toRender: {
            """
            XXXXXX....
            XXXXXX....
            XXXXXX....
            ..........
            """
        }
    }

    @Test
    func `Expanding View with Frame - Top Leading`() async throws {
        expectView(in: Size(width: 8, height: 4)) {
            ExpandingView(char: "X")
                .frame(width: 5, height: 3, alignment: .topLeading)
        } toRender: {
            """
            XXXXX...
            XXXXX...
            XXXXX...
            ........
            """
        }
    }

    @Test
    func `Expanding View with Frame - Bottom Trailing`() async throws {
        expectView(in: Size(width: 8, height: 4)) {
            ExpandingView(char: "X")
                .frame(width: 5, height: 3)
                .frame(width: 8, height: 4, alignment: .bottomTrailing)
        } toRender: {
            """
            ........
            ...XXXXX
            ...XXXXX
            ...XXXXX
            """
        }
    }

    // MARK: - VStack with Frame

    @Test
    func `VStack with Frame`() async throws {
        expectView(in: Size(width: 10, height: 3)) {
            VStack {
                Text("A")
                Text("B")
            }
            .frame(width: 5, height: 3, alignment: .topLeading)
        } toRender: {
            """
            A.........
            B.........
            ..........
            """
        }
    }

    @Test
    func `VStack with Frame - Center`() async throws {
        expectView(in: Size(width: 3, height: 4)) {
            VStack {
                Text("A")
                Text("B")
            }
            .frame(width: 3, height: 4)
        } toRender: {
            """
            ...
            .A.
            .B.
            ...
            """
        }
    }

    @Test
    func `VStack with Frame - Bottom Trailing`() async throws {
        expectView(in: Size(width: 5, height: 4)) {
            VStack {
                Text("A")
                Text("B")
            }
            .frame(width: 4, height: 3, alignment: .bottomTrailing)
        } toRender: {
            """
            .....
            ...A.
            ...B.
            .....
            """
        }
    }
}
