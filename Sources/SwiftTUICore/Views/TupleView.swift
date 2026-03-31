//
//  TupleView.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 10/03/2026.
//

import Foundation
import AttributeGraph

struct TupleView<each V: View>: View, PrimitiveView {
    private let childViews: (repeat each V)

    init(_ childViews: repeat each V) {
        self.childViews = (repeat each childViews)
    }
}

extension TupleView {
    static func makeView(
        _ view: Attribute<Self>,
        inputs: ViewInputs
    ) -> ViewOutputs {
        fatalError("Not implemented")
    }

    static func makeViewList(
        _ view: Attribute<Self>,
        inputs: ViewListInputs
    ) -> ViewListOutputs {
        let viewTypes: (repeat each V).Type = (repeat each V).self
        let tupleType: TupleType = TupleType(viewTypes)
        var viewListOutputs: [ViewListOutputs] = []

        for index in (0..<tupleType.count) {
            guard let childViewType = tupleType.type(at: index) as? any View.Type else {
                continue
            }

            let childViewOutputs: ViewListOutputs = makeChildViewListOutputs(
                view,
                inputs: inputs,
                tupleType: tupleType,
                tupleIndex: index,
                tupleChildViewType: childViewType
            )
            viewListOutputs.append(childViewOutputs)
        }

        return .concat(viewListOutputs, label: "TupleView ViewList")
    }

    private static func makeChildViewListOutputs<T: View>(
        _ view: Attribute<Self>,
        inputs: ViewListInputs,
        tupleType: TupleType,
        tupleIndex: Int,
        tupleChildViewType: T.Type
    ) -> ViewListOutputs {
        let childViewTupleMemoryOffset: Int = tupleType.elementOffset(at: tupleIndex)
        let childView: Attribute<T> = view.unsafeOffset(
            at: childViewTupleMemoryOffset,
            as: tupleChildViewType
        )
        view.label = "\(Self.self)"
        childView.label = "\(T.self)"
        return T.makeViewList(childView, inputs: inputs)
    }
}
