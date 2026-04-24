//
//  File.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 10/03/2026.
//

import AttributeGraph
import Foundation
import Geometry
import Testing

@testable import SwiftTUI
@testable import SwiftTUICore

@Suite("@State")
@MainActor
struct StateTests {
    @Test
    func `Within a view`() async {
        await expectView(in: Size(width: 3, height: 3)) {
            BaseView()
        } toRender: {
            """
            0..
            ...
            ...
            """
        }
    }

    @Test
    func `Within view list`() async {
        await expectView(in: Size(width: 3, height: 3)) {
            RootLayout {
                BaseView()
            }
        } toRender: {
            """
            ...
            .0.
            ...
            """
        }
    }

    @Test
    func `Within a view modifier`() async {
        await expectView(in: Size(width: 3, height: 3)) {
            Text("A")
                .modifier(BaseViewModifier())
        } toRender: {
            """
            A..
            ...
            ...
            """
        }
    }

    @Test
    func `Update within a view`() async {
        @Attribute var screenPosition: Point = .zero
        @Attribute var screenSize: Size = .init(width: 3, height: 3)
        @Attribute var viewPhase: ViewPhase = .active
        let inputs = ViewInputs(
            position: $screenPosition,
            size: $screenSize,
            phase: $viewPhase,
            environment: .init(wrappedValue: .init()),
            storage: .init()
        )

        @Attribute var view = BaseView()

        let outputs = type(of: view).makeView($view, inputs: inputs)

        await expectDisplayList(outputs.displayList, in: screenSize) {
            """
            0..
            ...
            ...
            """
        }

        view.count = 1

        await expectDisplayList(outputs.displayList, in: screenSize) {
            """
            1..
            ...
            ...
            """
        }
    }

    @Test
    func `Update within a view modifier`() async {
        @Attribute var screenPosition: Point = .zero
        @Attribute var screenSize: Size = .init(width: 3, height: 3)
        @Attribute var viewPhase: ViewPhase = .active
        let inputs = ViewInputs(
            position: $screenPosition,
            size: $screenSize,
            phase: $viewPhase,
            environment: .init(wrappedValue: .init()),
            storage: .init()
        )

        let modifier: BaseViewModifier = .init()
        @Attribute var view = Text("A")
            .modifier(modifier)

        let outputs = type(of: view).makeView($view, inputs: inputs)

        await expectDisplayList(outputs.displayList, in: screenSize) {
            """
            A..
            ...
            ...
            """
        }

        modifier.width = 3

        await expectDisplayList(outputs.displayList, in: screenSize) {
            """
            ..A
            ...
            ...
            """
        }
    }
}

private struct BaseView: View {
    @State var count: Int = 0

    var body: some View {
        Text("\(count)")
    }
}

private struct BaseViewModifier: ViewModifier {
    @State var width: GeometryUnit = 1

    func body(content: Content) -> some View {
        content
            .frame(width: width, alignment: .trailing)
    }
}
