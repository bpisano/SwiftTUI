//
//  BindingTests.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 2026-05-21.
//

import AttributeGraph
import Foundation
import Geometry
import Testing

@testable import SwiftTUI
@testable import SwiftTUICore

@Suite("@Binding")
@MainActor
struct BindingTests {
    @Test
    func `Get and set through closures`() {
        final class Box { var value: Int = 0 }
        let box = Box()
        let binding = Binding<Int>(
            get: { box.value },
            set: { box.value = $0 }
        )

        #expect(binding.wrappedValue == 0)
        binding.wrappedValue = 42
        #expect(box.value == 42)
        #expect(binding.wrappedValue == 42)
    }

    @Test
    func `projectedValue returns self`() {
        final class Box { var value: Int = 1 }
        let box = Box()
        let binding = Binding<Int>(
            get: { box.value },
            set: { box.value = $0 }
        )

        binding.projectedValue.wrappedValue = 7
        #expect(box.value == 7)
    }

    @Test
    func `constant binding ignores writes`() {
        let binding = Binding<Int>.constant(99)
        #expect(binding.wrappedValue == 99)
        binding.wrappedValue = 0
        #expect(binding.wrappedValue == 99)
    }

    @Test
    func `Dynamic member subscript derives child binding`() {
        struct User { var name: String; var age: Int }
        final class Box { var user = User(name: "A", age: 1) }
        let box = Box()
        let userBinding = Binding<User>(
            get: { box.user },
            set: { box.user = $0 }
        )

        let nameBinding = userBinding.name
        #expect(nameBinding.wrappedValue == "A")
        nameBinding.wrappedValue = "B"
        #expect(box.user.name == "B")
        #expect(box.user.age == 1)
    }

    @Test
    func `State projectedValue produces a usable binding within a view`() async {
        await expectView(in: Size(width: 3, height: 3)) {
            ParentBinding()
        } toRender: {
            """
            5..
            ...
            ...
            """
        }
    }

    @Test
    func `Binding mutation through child triggers re-render`() async {
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

        let probe: Probe = .init()
        @Attribute var view = MutatingParent(probe: probe)

        let outputs = type(of: view).makeView($view, inputs: inputs)

        await expectDisplayList(outputs.displayList, in: screenSize) {
            """
            0..
            ...
            ...
            """
        }

        probe.binding?.wrappedValue = 3

        await expectDisplayList(outputs.displayList, in: screenSize) {
            """
            3..
            ...
            ...
            """
        }
    }
}

@MainActor
private final class Probe {
    var binding: Binding<Int>?
}

private struct ParentBinding: View {
    @State var count: Int = 5

    var body: some View {
        ChildBinding(value: $count)
    }
}

private struct ChildBinding: View {
    @Binding var value: Int

    var body: some View {
        Text("\(value)")
    }
}

private struct MutatingParent: View {
    @State var count: Int = 0
    let probe: Probe

    var body: some View {
        CapturingChild(value: $count, probe: probe)
    }
}

private struct CapturingChild: View {
    @Binding var value: Int
    let probe: Probe

    var body: some View {
        let _ = { probe.binding = $value }()
        Text("\(value)")
    }
}
