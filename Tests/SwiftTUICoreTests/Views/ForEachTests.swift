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
    func `Layout update with stable id`() async throws {
        @Attribute var screenPosition: Point = .zero
        @Attribute var screenSize: Size = .init(width: 9, height: 3)
        @Attribute var viewPhase: ViewPhase = .active
        @Attribute var environment: EnvironmentValues = .init()
        let inputs = ViewInputs(
            position: $screenPosition,
            size: $screenSize,
            phase: $viewPhase,
            environment: $environment,
            storage: .init()
        )

        @Attribute var items: [PaddedItem] = [PaddedItem(id: 1, leading: 0)]
        @Attribute var view = VStack(alignment: .leading, spacing: 0) {
            ForEach(items) { item in
                Text("X").padding(.leading, item.leading)
            }
        }

        let outputs = type(of: view).makeView($view, inputs: inputs)

        await expectDisplayList(outputs.displayList, in: screenSize) {
            """
            X........
            .........
            .........
            """
        }

        items = [PaddedItem(id: 1, leading: 2)]

        await expectDisplayList(outputs.displayList, in: screenSize) {
            """
            ..X......
            .........
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
    func `Reorder keeps stable ids and does not retrigger appearance`() async throws {
        let graph = Graph()
        Graph.withCurrent(graph) {
            @Attribute var screenPosition: Point = .zero
            @Attribute var screenSize: Size = .init(width: 12, height: 4)
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

            var onAppearCallCountById: [Int: Int] = [:]
            var onDisappearCallCountById: [Int: Int] = [:]

            @Attribute var view = VStack(alignment: .leading, spacing: 0) {
                ForEach(users) { user in
                    Text(user.name)
                        .onAppear {
                            onAppearCallCountById[user.id, default: 0] += 1
                        }
                        .onDisappear {
                            onDisappearCallCountById[user.id, default: 0] += 1
                        }
                }
            }

            let outputs = type(of: view).makeView($view, inputs: inputs)

            _ = outputs.displayList.wrappedValue
            CallbackQueue.shared.executeAll()

            #expect(onAppearCallCountById == [1: 1, 2: 1, 3: 1])
            #expect(onDisappearCallCountById.isEmpty)

            users = [
                User(id: 3, name: "Charlie"),
                User(id: 1, name: "Alice"),
                User(id: 2, name: "Bob")
            ]

            _ = outputs.displayList.wrappedValue
            CallbackQueue.shared.executeAll()

            #expect(onAppearCallCountById == [1: 1, 2: 1, 3: 1])
            #expect(onDisappearCallCountById.isEmpty)
        }
    }

    @Test
    func `Nested ForEach leaf ids stay unique and stable across reorder`() async throws {
        let graph = Graph()
        Graph.withCurrent(graph) {
            @Attribute var screenPosition: Point = .zero
            @Attribute var screenSize: Size = .init(width: 30, height: 8)
            @Attribute var viewPhase: ViewPhase = .active
            let inputs = ViewInputs(
                position: $screenPosition,
                size: $screenSize,
                phase: $viewPhase,
                environment: .init(wrappedValue: .init()),
                storage: .init()
            )

            @Attribute var rows: [NestedRow] = [
                .init(
                    id: 1,
                    children: [
                        .init(id: 10, label: "A"),
                        .init(id: 11, label: "B")
                    ]
                ),
                .init(
                    id: 2,
                    children: [
                        .init(id: 20, label: "C"),
                        .init(id: 21, label: "D")
                    ]
                )
            ]

            @Attribute var view = ForEach(rows) { row in
                ForEach(row.children) { child in
                    TupleView(
                        Text("\(row.id)-\(child.label)L"),
                        Text("\(row.id)-\(child.label)R")
                    )
                }
            }

            let viewListOutputs = type(of: view).makeViewList(
                $view,
                inputs: .init(viewInputs: inputs)
            )

            var startIndex = 0
            let initialOutputs = viewListOutputs.makeViewOutputs(
                startIndex: &startIndex,
                inputs: inputs,
                makeViewOutputs: captureViewId
            )
            let initialIds = initialOutputs.map(\.viewId)

            #expect(Set(initialIds).count == initialIds.count)

            rows = [
                .init(
                    id: 2,
                    children: [
                        .init(id: 21, label: "D"),
                        .init(id: 20, label: "C")
                    ]
                ),
                .init(
                    id: 1,
                    children: [
                        .init(id: 11, label: "B"),
                        .init(id: 10, label: "A")
                    ]
                )
            ]

            startIndex = 0
            let reorderedOutputs = viewListOutputs.makeViewOutputs(
                startIndex: &startIndex,
                inputs: inputs,
                makeViewOutputs: captureViewId
            )
            let reorderedIds = reorderedOutputs.map(\.viewId)

            #expect(Set(reorderedIds).count == reorderedIds.count)
            #expect(Set(initialIds) == Set(reorderedIds))
        }
    }

    @Test
    func `Insert remove reorder cycles clean graph and do not accumulate`() async throws {
        let graph = Graph()
        Graph.withCurrent(graph) {
            @Attribute var screenPosition: Point = .zero
            @Attribute var screenSize: Size = .init(width: 12, height: 4)
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
            @Attribute var view = VStack(alignment: .leading, spacing: 0) {
                ForEach(users) { user in
                    Text(user.name)
                }
            }

            let outputs = type(of: view).makeView($view, inputs: inputs)

            @MainActor func render() {
                _ = outputs.displayList.wrappedValue
                CallbackQueue.shared.executeAll()
            }

            render()

            users = [
                User(id: 3, name: "Charlie"),
                User(id: 1, name: "Alice"),
                User(id: 2, name: "Bob")
            ]
            render()

            users = [
                User(id: 1, name: "Alice"),
                User(id: 2, name: "Bob")
            ]
            render()

            var digraph = graph.digraph
            #expect(!digraph.contains("ForEach Child View 3"))

            users = [
                User(id: 1, name: "Alice"),
                User(id: 2, name: "Bob"),
                User(id: 3, name: "Charlie")
            ]
            render()

            let attributeCountAfterWarmup = graph.attributeCount
            let edgeCountAfterWarmup = graph.totalEdgeCount

            for cycle in 0..<8 {
                users = cycle.isMultiple(of: 2)
                ? [
                    User(id: 3, name: "Charlie"),
                    User(id: 1, name: "Alice"),
                    User(id: 2, name: "Bob")
                ]
                : [
                    User(id: 2, name: "Bob"),
                    User(id: 3, name: "Charlie"),
                    User(id: 1, name: "Alice")
                ]
                render()

                users = [
                    User(id: 1, name: "Alice"),
                    User(id: 2, name: "Bob")
                ]
                render()

                digraph = graph.digraph
                #expect(!digraph.contains("ForEach Child View 3"))

                users = [
                    User(id: 1, name: "Alice"),
                    User(id: 2, name: "Bob"),
                    User(id: 3, name: "Charlie")
                ]
                render()

                digraph = graph.digraph
                #expect(digraph.contains("ForEach Child View 3"))
            }

            #expect(
                graph.attributeCount == attributeCountAfterWarmup,
                "Attribute count grew from \(attributeCountAfterWarmup) to \(graph.attributeCount)"
            )
            #expect(
                graph.totalEdgeCount <= edgeCountAfterWarmup,
                "Edge count grew from \(edgeCountAfterWarmup) to \(graph.totalEdgeCount)"
            )
        }
    }

    @Test
    func `LayoutView retains static siblings across dynamic list updates`() async throws {
        let graph = Graph()
        Graph.withCurrent(graph) {
            @Attribute var screenPosition: Point = .zero
            @Attribute var screenSize: Size = .init(width: 12, height: 6)
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
            @Attribute var view = VStack(alignment: .leading, spacing: 0) {
                Text("Header")
                Text("Status")
                ForEach(users) { user in
                    Text(user.name)
                }
                Text("Footer")
            }

            let outputs = type(of: view).makeView($view, inputs: inputs)

            @MainActor func render() {
                _ = outputs.displayList.wrappedValue
                CallbackQueue.shared.executeAll()
            }

            render()

            users = [
                User(id: 3, name: "Charlie"),
                User(id: 1, name: "Alice"),
                User(id: 2, name: "Bob")
            ]
            render()

            users = [
                User(id: 1, name: "Alice"),
                User(id: 2, name: "Bob")
            ]
            render()

            users = [
                User(id: 1, name: "Alice"),
                User(id: 2, name: "Bob"),
                User(id: 3, name: "Charlie")
            ]
            render()

            let attributeCountAfterWarmup = graph.attributeCount
            let edgeCountAfterWarmup = graph.totalEdgeCount

            for cycle in 0..<8 {
                users = cycle.isMultiple(of: 2)
                ? [
                    User(id: 3, name: "Charlie"),
                    User(id: 1, name: "Alice"),
                    User(id: 2, name: "Bob")
                ]
                : [
                    User(id: 2, name: "Bob"),
                    User(id: 3, name: "Charlie"),
                    User(id: 1, name: "Alice")
                ]
                render()

                users = [
                    User(id: 1, name: "Alice"),
                    User(id: 2, name: "Bob")
                ]
                render()

                users = [
                    User(id: 1, name: "Alice"),
                    User(id: 2, name: "Bob"),
                    User(id: 3, name: "Charlie")
                ]
                render()
            }

            #expect(
                graph.attributeCount == attributeCountAfterWarmup,
                "Attribute count grew from \(attributeCountAfterWarmup) to \(graph.attributeCount)"
            )
            #expect(
                graph.totalEdgeCount <= edgeCountAfterWarmup,
                "Edge count grew from \(edgeCountAfterWarmup) to \(graph.totalEdgeCount)"
            )
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

@MainActor
private func captureViewId(
    _ index: inout Int,
    _ viewId: ViewId,
    _ inputs: ViewInputs,
    _ makeViewOutputs: ViewList.MakeViewOutputs
) -> ViewOutputs? {
    let rawOutputs = makeViewOutputs(inputs)
    return ViewOutputs(
        viewId: viewId,
        layoutComputer: rawOutputs.layoutComputer,
        displayList: rawOutputs.displayList
    )
}

private struct PaddedItem: Identifiable {
    let id: Int
    let leading: Double
}

private struct NestedRow: Identifiable {
    let id: Int
    let children: [NestedChild]
}

private struct NestedChild: Identifiable {
    let id: Int
    let label: String
}
