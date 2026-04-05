//
//  File.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 29/03/2026.
//

import Foundation
import Geometry
import Testing

@testable import AttributeGraph
@testable import SwiftTUICore

@Suite(".padding")
@MainActor
struct PaddingTests {
    @Test
    func `Leading padding`() async throws {
        await expectView(in: Size(width: 10, height: 3)) {
            Text("Alice")
                .padding(.leading, 1)
        } toRender: {
            """
            .Alice....
            ..........
            ..........
            """
        }
    }

    @Test
    func `Top padding`() async throws {
        await expectView(in: Size(width: 10, height: 3)) {
            Text("Alice")
                .padding(.top, 1)
        } toRender: {
            """
            ..........
            Alice.....
            ..........
            """
        }
    }

    @Test
    func `Trailing padding`() async throws {
        await expectView(in: Size(width: 10, height: 3)) {
            HStack {
                Text("Alice")
                    .padding(.trailing, 1)
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
        func `Bottom padding`() async throws {
            await expectView(in: Size(width: 10, height: 3)) {
            VStack(alignment: .leading) {
                Text("Alice")
                    .padding(.bottom, 1)
                Text("Bob")
            }
        } toRender: {
            """
            Alice.....
            ..........
            Bob.......
            """
        }
    }

    @Test
    func `Set padding`() async throws {
        await expectView(in: Size(width: 10, height: 4)) {
            VStack(alignment: .leading) {
                Text("Alice")
                    .padding([.bottom, .top], 1)
                Text("Bob")
            }
        } toRender: {
            """
            ..........
            Alice.....
            ..........
            Bob.......
            """
        }
    }

    @Test
    func `Edge padding`() async throws {
        await expectView(in: Size(width: 10, height: 4)) {
            VStack(alignment: .leading) {
                Text("Alice")
                    .padding(.vertical, 1)
                Text("Bob")
            }
        } toRender: {
            """
            ..........
            Alice.....
            ..........
            Bob.......
            """
        }
    }

    @Test
    func `All padding`() async throws {
        await expectView(in: Size(width: 10, height: 4)) {
            VStack(alignment: .leading) {
                HStack {
                    Text("Alice")
                        .padding(1)
                    Text("Bob")
                }
                Text("Charlie")
            }
        } toRender: {
            """
            ..........
            .Alice.Bob
            ..........
            Charlie...
            """
        }
    }

    @Test
    func `Default padding`() async throws {
        await expectView(in: Size(width: 10, height: 4)) {
            VStack(alignment: .leading) {
                HStack {
                    Text("Alice")
                        .padding()
                    Text("Bob")
                }
                Text("Charlie")
            }
        } toRender: {
            """
            ..........
            .Alice.Bob
            ..........
            Charlie...
            """
        }
    }
}
