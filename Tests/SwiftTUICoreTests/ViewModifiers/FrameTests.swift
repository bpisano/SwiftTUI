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

@Suite("Frame Modifier")
struct FrameTests {
    // MARK: - Basic Frame Tests

    @Test("Text with Fixed Width")
    func textWithFixedWidth() async throws {
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

    @Test("Text with Fixed Height")
    func textWithFixedHeight() async throws {
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

    @Test("Text with Fixed Width and Height")
    func textWithFixedWidthAndHeight() async throws {
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

    @Test("Top Leading Alignment")
    func topLeadingAlignment() async throws {
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

    @Test("Top Center Alignment")
    func topCenterAlignment() async throws {
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

    @Test("Top Trailing Alignment")
    func topTrailingAlignment() async throws {
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

    @Test("Center Leading Alignment")
    func centerLeadingAlignment() async throws {
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

    @Test("Center Alignment (Default)")
    func centerAlignment() async throws {
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

    @Test("Center Trailing Alignment")
    func centerTrailingAlignment() async throws {
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

    @Test("Bottom Leading Alignment")
    func bottomLeadingAlignment() async throws {
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

    @Test("Bottom Center Alignment")
    func bottomCenterAlignment() async throws {
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

    @Test("Bottom Trailing Alignment")
    func bottomTrailingAlignment() async throws {
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

    @Test("Width Only - Leading")
    func widthOnlyLeading() async throws {
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

    @Test("Width Only - Center (Default)")
    func widthOnlyCenter() async throws {
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

    @Test("Width Only - Trailing")
    func widthOnlyTrailing() async throws {
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

    @Test("Height Only - Top")
    func heightOnlyTop() async throws {
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

    @Test("Height Only - Center (Default)")
    func heightOnlyCenter() async throws {
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

    @Test("Height Only - Bottom")
    func heightOnlyBottom() async throws {
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

    @Test("Expanding View with Frame")
    func expandingViewWithFrame() async throws {
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

    @Test("Expanding View with Frame - Top Leading")
    func expandingViewTopLeading() async throws {
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

    @Test("Expanding View with Frame - Bottom Trailing")
    func expandingViewBottomTrailing() async throws {
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

    @Test("VStack with Frame")
    func vstackWithFrame() async throws {
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

    @Test("VStack with Frame - Center")
    func vstackWithFrameCenter() async throws {
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

    @Test("VStack with Frame - Bottom Trailing")
    func vstackWithFrameBottomTrailing() async throws {
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
