//
//  File.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 15/03/2026.
//

import Foundation
import Testing
import Geometry
@testable import AttributeGraph
@testable import SwiftTUICore

@Suite("VStack")
struct VStackTests {
    @Test
    func `One Element`() async throws {
        let screenSize: Size = .init(width: 6, height: 2)
        expectView(in: screenSize) {
            VStack {
                Text("Alice")
            }
        } toRender: {
            """
            Alice.
            ......
            """
        }
    }

    @Test
    func `Multiple Elements`() async throws {
        let screenSize: Size = .init(width: 6, height: 3)
        expectView(in: screenSize) {
            VStack {
                Text("Alice")
                Text("Bob")
            }
        } toRender: {
            """
            Alice.
            Bob...
            ......
            """
        }
    }

    @Test
    func `Nested`() async throws {
        let screenSize: Size = .init(width: 10, height: 5)
        expectView(in: screenSize) {
            VStack {
                Text("Alice")
                VStack {
                    Text("Bob")
                    Text("Charlie")
                }
            }
        } toRender: {
            """
            Alice.....
            Bob.......
            Charlie...
            ..........
            ..........
            """
        }
    }
}
