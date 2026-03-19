//
//  File.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 19/03/2026.
//

import Foundation
import Geometry
import Testing

@testable import AttributeGraph
@testable import SwiftTUICore

@Suite("ZStack")
struct ZStackTests {
    @Test
    func `2 views on top of each other`() {
        expectView(in: Size(width: 10, height: 2)) {
            ZStack {
                Text("Alice")
                Text("Bob")
            }
        } toRender: {
            """
            ABobe.....
            ..........
            """
        }
    }

    @Test
    func `Text on top of expanding`() {
        expectView(in: Size(width: 9, height: 3)) {
            ZStack {
                ExpandingView(char: "X")
                Text("Alice")
            }
        } toRender: {
            """
            XXXXXXXXX
            XXAliceXX
            XXXXXXXXX
            """
        }
    }

    @Test
    func `Expanding on top of Text`() {
        expectView(in: Size(width: 9, height: 3)) {
            ZStack {
                Text("Alice")
                ExpandingView(char: "X")
            }
        } toRender: {
            """
            XXXXXXXXX
            XXXXXXXXX
            XXXXXXXXX
            """
        }
    }

    @Test
    func `Alignment topLeading`() {
        expectView(in: Size(width: 9, height: 3)) {
            ZStack(alignment: .topLeading) {
                ExpandingView(char: "X")
                Text("Alice")
            }
        } toRender: {
            """
            AliceXXXX
            XXXXXXXXX
            XXXXXXXXX
            """
        }
    }

    @Test
    func `Alignment bottomTrailing`() {
        expectView(in: Size(width: 9, height: 3)) {
            ZStack(alignment: .bottomTrailing) {
                ExpandingView(char: "X")
                Text("Alice")
            }
        } toRender: {
            """
            XXXXXXXXX
            XXXXXXXXX
            XXXXAlice
            """
        }
    }
}
