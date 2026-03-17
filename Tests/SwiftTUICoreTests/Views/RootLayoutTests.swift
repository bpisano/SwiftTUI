//
//  File.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 17/03/2026.
//

import Foundation
import Geometry
import Testing

@testable import AttributeGraph
@testable import SwiftTUICore

@Suite("RootLayout")
struct RootLayoutTests {
    @Test
    func `Single Child`() async throws {
        expectView(in: Size(width: 9, height: 3)) {
            RootLayout {
                Text("Alice")
            }
        } toRender: {
            """
            .........
            ..Alice..
            .........
            """
        }
    }

    @Test
    func `Multiple Childs`() async throws {
        expectView(in: Size(width: 9, height: 4)) {
            RootLayout {
                Text("Alice")
                Text("Bob")
            }
        } toRender: {
            """
            .........
            ..Alice..
            ...Bob...
            .........
            """
        }
    }

    @Test
    func `Bounds constraint`() async throws {
        expectView(in: Size(width: 3, height: 4)) {
            RootLayout {
                Text("Alice")
            }
        } toRender: {
            """
            ...
            Ali
            ce.
            ...
            """
        }
    }

    @Test
    func `Nested views`() async throws {
        expectView(in: Size(width: 9, height: 5)) {
            RootLayout {
                VStack(spacing: 1) {
                    Text("Alice")
                    Text("Bob")
                }
            }
        } toRender: {
            """
            .........
            ..Alice..
            .........
            ...Bob...
            .........
            """
        }
    }
}
