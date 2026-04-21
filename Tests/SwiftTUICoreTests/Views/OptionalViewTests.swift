//
//  OptionalViewTests.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 09/04/2026.
//

import Foundation
import Testing
import Geometry

@testable import AttributeGraph
@testable import SwiftTUICore

@Suite("OptionalView")
@MainActor
struct OptionalViewTests {
    @Test
    func `Static present optional`() async throws {
        await expectView(in: Size(width: 9, height: 2)) {
            let name: String? = "Alice"
            if let name {
                Text(name)
            }
        } toRender: {
            """
            Alice....
            .........
            """
        }
    }

    @Test
    func `Static nil optional`() async throws {
        await expectView(in: Size(width: 9, height: 2)) {
            let name: String? = nil
            if let name {
                Text(name)
            }
        } toRender: {
            """
            .........
            .........
            """
        }
    }

    @Test
    func `Dynamic optional toggles content`() async throws {
        @Attribute var screenPosition: Point = .zero
        @Attribute var screenSize: Size = .init(width: 9, height: 2)
        @Attribute var viewPhase: ViewPhase = .active
        let inputs = ViewInputs(
            position: $screenPosition,
            size: $screenSize,
            phase: $viewPhase,
            environment: .init(wrappedValue: .init()),
            storage: .init()
        )

        @Attribute var name: String? = "Alice"
        @Attribute var view = VStack {
            if let name {
                Text(name)
            }
        }

        let outputs = type(of: view).makeView($view, inputs: inputs)

        await expectDisplayList(outputs.displayList, in: screenSize) {
            """
            Alice....
            .........
            """
        }

        name = nil

        await expectDisplayList(outputs.displayList, in: screenSize) {
            """
            .........
            .........
            """
        }

        name = "Bob"

        await expectDisplayList(outputs.displayList, in: screenSize) {
            """
            Bob......
            .........
            """
        }
    }

    @Test
    func `Inside view list`() async throws {
        await expectView(in: Size(width: 9, height: 2)) {
            VStack(alignment: .leading) {
                let name: String? = "Alice"
                if let name {
                    Text(name)
                }
                Text("Charlie")
            }
        } toRender: {
            """
            Alice....
            Charlie..
            """
        }
    }

    @Test
    func `Nil optional inside view list`() async throws {
        await expectView(in: Size(width: 9, height: 2)) {
            VStack(alignment: .leading) {
                let name: String? = nil
                if let name {
                    Text(name)
                }
                Text("Charlie")
            }
        } toRender: {
            """
            Charlie..
            .........
            """
        }
    }
}
