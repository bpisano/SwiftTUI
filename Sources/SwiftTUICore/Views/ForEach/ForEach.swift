//
//  ForEach.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 10/03/2026.
//

import Foundation
import AttributeGraph

/// A view that produces a child view for each element in a collection.
///
/// Each element is identified by the value at the given key path, which the
/// engine uses to keep child views stable as the collection changes.
///
/// ```swift
/// ForEach(items, id: \.name) { item in
///     Text(item.name)
/// }
/// ```
public struct ForEach<Data: RandomAccessCollection, ID: Hashable, Content: View>: View, PrimitiveView {
    let data: Data
    let id: KeyPath<Data.Element, ID>
    let makeChildView: (Data.Element) -> Content

    /// Creates a view that maps each element of a collection to a child view,
    /// using a key path for identity.
    ///
    /// - Parameters:
    ///   - data: The collection to iterate over.
    ///   - id: A key path to a value that uniquely identifies each element.
    ///   - makeChildView: A view builder that produces a view for an element.
    public init(
        _ data: Data,
        id: KeyPath<Data.Element, ID>,
        @ViewBuilder _ makeChildView: @escaping (Data.Element) -> Content
    ) {
        self.data = data
        self.id = id
        self.makeChildView = makeChildView
    }
}

extension ForEach where Data.Element: Identifiable, ID == Data.Element.ID {
    /// Creates a view that maps each element of a collection to a child view,
    /// using the element's `Identifiable` identity.
    ///
    /// - Parameters:
    ///   - data: The collection of identifiable elements to iterate over.
    ///   - makeChildView: A view builder that produces a view for an element.
    public init(
        _ data: Data,
        @ViewBuilder _ makeChildView: @escaping (Data.Element) -> Content
    ) {
        self.init(
            data,
            id: \.id,
            makeChildView
        )
    }
}

extension ForEach {
    public static func makeView(
        _ view: Attribute<Self>,
        inputs: ViewInputs
    ) -> ViewOutputs {
        fatalError("Not implemented")
    }

    public static func makeViewList(
        _ view: Attribute<Self>,
        inputs: ViewListInputs
    ) -> ViewListOutputs {
        let state = ForEachState<Data, ID, Content>()

        let viewList: Attribute<any ViewList> = Attribute("ForEach ViewList") {
            state.update(with: view, inputs: inputs)
            return ForEachViewList(
                view: view,
                state: state,
                implicitId: inputs.implicitId,
                viewIds: state.viewIds(forEachImplicitId: inputs.implicitId)
            )
        }

        return .init(views: .dynamicList(viewList), nextImplicitId: inputs.implicitId + 1)
    }
}

extension ForEach: @MainActor AttributeValueRepresentable {
    public var attributeValueDescription: String {
        "ForEach with \(data.count) elements"
    }
}
