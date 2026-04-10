//
//  File.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 31/03/2026.
//

import Foundation
import Testing
import Geometry

@testable import AttributeGraph
@testable import SwiftTUICore

@Suite("ConditionalView")
@MainActor
struct ConditionalViewTests {
    @Test
    func `Static condition`() async throws {
        await expectView(in: Size(width: 9, height: 2)) {
            if true {
                Text("Alice")
            } else {
                Text("Bob")
            }
        } toRender: {
            """
            Alice....
            .........
            """
        }
    }

    @Test
    func `Dynamic condition`() async throws {
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

        @Attribute var showAlice = true
        @Attribute var view = VStack {
            if showAlice {
                Text("Alice")
            } else {
                Text("Bob")
            }
        }

        let outputs = type(of: view).makeView($view, inputs: inputs)

        await expectDisplayList(outputs.displayList, in: screenSize) {
            """
            Alice....
            .........
            """
        }

        showAlice = false

        await expectDisplayList(outputs.displayList, in: screenSize) {
            """
            Bob......
            .........
            """
        }

        showAlice = true

        await expectDisplayList(outputs.displayList, in: screenSize) {
            """
            Alice....
            .........
            """
        }
    }

    @Test
    func `Dynamic condition with empty view`() async throws {
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

        @Attribute var showAlice = true
        @Attribute var view = VStack {
            if showAlice {
                Text("Alice")
            }
        }

        let outputs = type(of: view).makeView($view, inputs: inputs)

        await expectDisplayList(outputs.displayList, in: screenSize) {
            """
            Alice....
            .........
            """
        }

        showAlice = false

        await expectDisplayList(outputs.displayList, in: screenSize) {
            """
            .........
            .........
            """
        }

        showAlice = true

        await expectDisplayList(outputs.displayList, in: screenSize) {
            """
            Alice....
            .........
            """
        }
    }

    @Test
    func `Inside view list`() async throws {
        await expectView(in: Size(width: 9, height: 2)) {
            VStack(alignment: .leading) {
                if true {
                    Text("Alice")
                } else {
                    Text("Bob")
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
}
