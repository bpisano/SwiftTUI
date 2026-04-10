//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 03/03/2026.
//

import Foundation
import Testing
import Geometry

@testable import AttributeGraph
@testable import SwiftTUICore

@Suite("ForEach")
@MainActor
struct ForEachTests {
    @Test
    func `Static content`() async throws {
        await expectView(in: Size(width: 9, height: 4)) {
            let users: [User] = [
                User(id: 1, name: "Alice"),
                User(id: 2, name: "Bob"),
                User(id: 3, name: "Charlie")
            ]
            VStack(alignment: .leading) {
                ForEach(users) { user in
                    Text(user.name)
                }
            }
        } toRender: {
            """
            Alice....
            Bob......
            Charlie..
            .........
            """
        }
    }

    @Test
    func `Insertion`() async throws {
        @Attribute var screenPosition: Point = .zero
        @Attribute var screenSize: Size = .init(width: 9, height: 4)
        @Attribute var viewPhase: ViewPhase = .active
        let inputs = ViewInputs(
            position: $screenPosition,
            size: $screenSize,
            phase: $viewPhase,
            environment: .init(wrappedValue: .init()),
            storage: .init()
        )

        @Attribute var users: [User] = [
            User(id: 1, name: "Alice"),
            User(id: 2, name: "Bob")
        ]
        @Attribute var view = VStack(alignment: .leading) {
            ForEach(users) { user in
                Text(user.name)
            }
        }

        let outputs = type(of: view).makeView($view, inputs: inputs)

        await expectDisplayList(outputs.displayList, in: screenSize) {
            """
            Alice....
            Bob......
            .........
            .........
            """
        }

        users.append(User(id: 3, name: "Charlie"))

        await expectDisplayList(outputs.displayList, in: screenSize) {
            """
            Alice....
            Bob......
            Charlie..
            .........
            """
        }
    }

    @Test
    func `Removal`() async throws {
        @Attribute var screenPosition: Point = .zero
        @Attribute var screenSize: Size = .init(width: 9, height: 4)
        @Attribute var viewPhase: ViewPhase = .active
        let inputs = ViewInputs(
            position: $screenPosition,
            size: $screenSize,
            phase: $viewPhase,
            environment: .init(wrappedValue: .init()),
            storage: .init()
        )

        @Attribute var users: [User] = [
            User(id: 1, name: "Alice"),
            User(id: 2, name: "Bob"),
            User(id: 3, name: "Charlie")
        ]
        @Attribute var view = VStack(alignment: .leading) {
            ForEach(users) { user in
                Text(user.name)
            }
        }

        let outputs = type(of: view).makeView($view, inputs: inputs)

        await expectDisplayList(outputs.displayList, in: screenSize) {
            """
            Alice....
            Bob......
            Charlie..
            .........
            """
        }

        users.removeLast()

        await expectDisplayList(outputs.displayList, in: screenSize) {
            """
            Alice....
            Bob......
            .........
            .........
            """
        }
    }

    @Test
    func `Update`() async throws {
        @Attribute var screenPosition: Point = .zero
        @Attribute var screenSize: Size = .init(width: 9, height: 4)
        @Attribute var viewPhase: ViewPhase = .active
        let inputs = ViewInputs(
            position: $screenPosition,
            size: $screenSize,
            phase: $viewPhase,
            environment: .init(wrappedValue: .init()),
            storage: .init()
        )

        @Attribute var users: [User] = [
            User(id: 1, name: "Alice"),
            User(id: 2, name: "Bob"),
            User(id: 3, name: "Charlie")
        ]
        @Attribute var view = VStack(alignment: .leading) {
            ForEach(users) { user in
                Text(user.name)
            }
        }

        let outputs = type(of: view).makeView($view, inputs: inputs)

        await expectDisplayList(outputs.displayList, in: screenSize) {
            """
            Alice....
            Bob......
            Charlie..
            .........
            """
        }

        users = [
            User(id: 1, name: "Alice"),
            User(id: 2, name: "Ben"),
            User(id: 3, name: "Charlie")
        ]

        await expectDisplayList(outputs.displayList, in: screenSize) {
            """
            Alice....
            Ben......
            Charlie..
            .........
            """
        }
    }

    @Test
    func `Reorder`() async throws {
        @Attribute var screenPosition: Point = .zero
        @Attribute var screenSize: Size = .init(width: 9, height: 4)
        @Attribute var viewPhase: ViewPhase = .active
        let inputs = ViewInputs(
            position: $screenPosition,
            size: $screenSize,
            phase: $viewPhase,
            environment: .init(wrappedValue: .init()),
            storage: .init()
        )

        @Attribute var users: [User] = [
            User(id: 1, name: "Alice"),
            User(id: 2, name: "Bob"),
            User(id: 3, name: "Charlie")
        ]
        @Attribute var view = VStack(alignment: .leading) {
            ForEach(users) { user in
                Text(user.name)
            }
        }

        let outputs = type(of: view).makeView($view, inputs: inputs)

        await expectDisplayList(outputs.displayList, in: screenSize) {
            """
            Alice....
            Bob......
            Charlie..
            .........
            """
        }

        users = [
            User(id: 1, name: "Alice"),
            User(id: 3, name: "Charlie"),
            User(id: 2, name: "Bob")
        ]

        await expectDisplayList(outputs.displayList, in: screenSize) {
            """
            Alice....
            Charlie..
            Bob......
            .........
            """
        }
    }

    @Test
    func `Element identifier stability`() async throws {
        @Attribute var items1: [String] = []
        @Attribute var items2: [String] = ["X"]

        @Attribute var view = RootLayout {
            VStack(alignment: .leading, spacing: 0) {
                Text("Header")
                ForEach(items1, id: \.self) { item in
                    Text(item)
                }
                Text("Section 2")
                ForEach(items2, id: \.self) { item in
                    Text(item)
                }
            }
        }

        let size = Size(width: 20, height: 9)
        @Attribute var screenPosition: Point = .zero
        @Attribute var screenSize: Size = size
        @Attribute var viewPhase: ViewPhase = .active
        let inputs = ViewInputs(
            position: $screenPosition,
            size: $screenSize,
            phase: $viewPhase,
            environment: .init(wrappedValue: .init()),
            storage: .init()
        )

        let outputs = type(of: view).makeView($view, inputs: inputs)

        await expectDisplayList(outputs.displayList, in: size) {
            """
            ....................
            ....................
            ....................
            .....Header.........
            .....Section 2......
            .....X..............
            ....................
            ....................
            ....................
            """
        }

        items1 = ["A", "B"]

        await expectDisplayList(outputs.displayList, in: size) {
            """
            ....................
            ....................
            .....Header.........
            .....A..............
            .....B..............
            .....Section 2......
            .....X..............
            ....................
            ....................
            """
        }
    }
}

private struct User: Identifiable {
    let id: Int
    let name: String
}
