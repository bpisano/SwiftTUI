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
struct ForEachTests {
    @Test
    func `Static content`() async throws {
        expectView(in: Size(width: 9, height: 4)) {
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

        expectDisplayList(outputs.displayList, in: screenSize) {
            """
            Alice....
            Bob......
            .........
            .........
            """
        }

        users.append(User(id: 3, name: "Charlie"))

        expectDisplayList(outputs.displayList, in: screenSize) {
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

        expectDisplayList(outputs.displayList, in: screenSize) {
            """
            Alice....
            Bob......
            Charlie..
            .........
            """
        }

        users.removeLast()

        expectDisplayList(outputs.displayList, in: screenSize) {
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

        expectDisplayList(outputs.displayList, in: screenSize) {
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

        expectDisplayList(outputs.displayList, in: screenSize) {
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

        expectDisplayList(outputs.displayList, in: screenSize) {
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

        expectDisplayList(outputs.displayList, in: screenSize) {
            """
            Alice....
            Charlie..
            Bob......
            .........
            """
        }
    }
}

private struct User: Identifiable {
    let id: Int
    let name: String
}
