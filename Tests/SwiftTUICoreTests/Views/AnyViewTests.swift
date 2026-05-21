//
//  AnyViewTests.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 21/05/2026.
//

import Foundation
import Geometry
import Testing

@testable import SwiftTUI
@testable import SwiftTUICore

@Suite("AnyView")
@MainActor
struct AnyViewTests {
    @Test
    func `AnyView around Text renders the same as Text`() async {
        await expectView(in: Size(width: 5, height: 1)) {
            AnyView(Text("hi"))
        } toRender: {
            "hi..."
        }
    }

    @Test
    func `AnyView around VStack renders nested content`() async {
        await expectView(in: Size(width: 3, height: 2)) {
            AnyView(
                VStack {
                    Text("a")
                    Text("b")
                }
            )
        } toRender: {
            """
            a..
            b..
            """
        }
    }

    @Test
    func `AnyView in a VStack preserves layout`() async {
        await expectView(in: Size(width: 3, height: 2)) {
            VStack {
                AnyView(Text("x"))
                AnyView(Text("y"))
            }
        } toRender: {
            """
            x..
            y..
            """
        }
    }
}
