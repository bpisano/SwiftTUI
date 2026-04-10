//
//  File.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 10/04/2026.
//

import Foundation
import Geometry
import Testing

@testable import AttributeGraph
@testable import SwiftTUICore

@Suite(".environment")
@MainActor
struct EnvironmentKeyWritingTest {
    @Test
    func `Default value is used when no modifier is applied`() async {
        await expectView(in: Size(width: 1, height: 1)) {
            LabelView()
        } toRender: {
            "X"
        }
    }

    @Test
    func `Modifier overrides the environment value for the child view`() async {
        await expectView(in: Size(width: 1, height: 1)) {
            LabelView()
                .environment(\.label, "Y")
        } toRender: {
            "Y"
        }
    }

    @Test
    func `Environment propagates through a container to all its children`() async {
        await expectView(in: Size(width: 1, height: 2)) {
            VStack(alignment: .leading) {
                LabelView()
                LabelView()
            }
            .environment(\.label, "Y")
        } toRender: {
            """
            Y
            Y
            """
        }
    }

    @Test
    func `Modifier does not leak to siblings`() async {
        await expectView(in: Size(width: 1, height: 2)) {
            VStack(alignment: .leading) {
                LabelView()
                    .environment(\.label, "Y")
                LabelView()
            }
        } toRender: {
            """
            Y
            X
            """
        }
    }

    @Test
    func `Inner modifier overrides outer modifier`() async {
        await expectView(in: Size(width: 1, height: 1)) {
            LabelView()
                .environment(\.label, "A")
                .environment(\.label, "B")
        } toRender: {
            "A"
        }
    }

    @Test
    func `Multiple keys coexist independently`() async {
        await expectView(in: Size(width: 2, height: 1)) {
            HStack(spacing: 0) {
                LabelView()
                    .environment(\.label, "A")
                LabelView()
                    .environment(\.label, "B")
            }
        } toRender: {
            "AB"
        }
    }

    @Test
    func `Updating the environment attribute propagates to the view`() async {
        @Attribute var screenPosition: Point = .zero
        @Attribute var screenSize: Size = .init(width: 1, height: 1)
        @Attribute var viewPhase: ViewPhase = .active
        @Attribute var environmentValues: EnvironmentValues = .init()
        let inputs = ViewInputs(
            position: $screenPosition,
            size: $screenSize,
            phase: $viewPhase,
            environment: $environmentValues,
            storage: .init()
        )

        @Attribute var view = LabelView()
        let outputs = LabelView.makeView($view, inputs: inputs)

        await expectDisplayList(outputs.displayList, in: screenSize) { "X" }

        var updated = environmentValues
        updated[LabelKey.self] = "Y"
        environmentValues = updated

        await expectDisplayList(outputs.displayList, in: screenSize) { "Y" }
    }
}

// MARK: - Helpers

private struct LabelKey: EnvironmentKey {
    static let defaultValue: String = "X"
}

extension EnvironmentValues {
    fileprivate var label: String {
        get { self[LabelKey.self] }
        set { self[LabelKey.self] = newValue }
    }
}

private struct LabelView: View {
    @Environment(\.label) var label

    var body: some View {
        Text(label)
    }
}
