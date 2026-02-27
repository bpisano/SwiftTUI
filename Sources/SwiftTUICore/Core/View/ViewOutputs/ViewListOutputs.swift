//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 25/11/2025.
//

import AttributeGraph
import Geometry
import Foundation

public struct ViewListOutputs {
    let views: Views
    let nextImplicitId: Int
    let explicitId: ViewId.Explicit?
    let count: Int?

    init(
        views: Views,
        nextImplicitId: Int,
        explicitId: ViewId.Explicit?,
        count: Int? = nil
    ) {
        self.views = views
        self.nextImplicitId = nextImplicitId
        self.explicitId = explicitId
        self.count = count
    }

    func makeViewList() -> ViewList {
        switch views {
        case .staticList(let elements):
            BaseViewList(
                elements: elements,
                implicitId: nextImplicitId - (count ?? 0),
                explicitId: explicitId
            )
        case .dynamicList(let list):
            list.wrappedValue
        }
    }
}

extension ViewListOutputs {
    static func empty(inputs: ViewListInputs) -> ViewListOutputs {
        .staticList(
            EmptyElement(),
            inputs: inputs,
            count: 0
        )
    }

    static func staticList(
        _ elements: any ViewListElements,
        inputs: ViewListInputs,
        count: Int,
    ) -> ViewListOutputs {
        ViewListOutputs(
            views: .staticList(elements),
            nextImplicitId: inputs.implicitId + count,
            explicitId: inputs.currentExplicitId(),
            count: count
        )
    }

    static func dynamicList(
        _ list: Attribute<ViewList>,
        inputs: ViewListInputs,
        count: Int? = nil
    ) -> ViewListOutputs {
        ViewListOutputs(
            views: .dynamicList(list),
            nextImplicitId: inputs.implicitId + (count ?? 0),
            explicitId: inputs.currentExplicitId()
        )
    }

    static func unaryViewList(
        inputs: ViewListInputs,
        body: @escaping (ViewInputs) -> ViewOutputs
    ) -> ViewListOutputs {
        .staticList(
            UnaryElement(body),
            inputs: inputs,
            count: 1
        )
    }

    static func concat(
        _ outputsList: [ViewListOutputs],
        inputs: ViewListInputs
    ) -> ViewListOutputs {
        guard !outputsList.isEmpty else {
            return .empty(inputs: inputs)
        }

        // Check if any of the outputs is dynamic
        let hasDynamic: Bool = outputsList.contains {
            guard case .dynamicList = $0.views else { return false }
            return true
        }

        if hasDynamic {
            // Create a dynamic merged list
            let viewLists: [ViewList] = outputsList.map { output in
                output.makeViewList()
            }
            // Merge them into a single dynamic list
            let mergedListAttribute: Attribute<ViewList> = Attribute {
                MergedViewList(viewLists)
            }
            mergedListAttribute.label = "Merged Dynamic View List"

            return .dynamicList(
                mergedListAttribute,
                inputs: inputs,
            )
        } else {
            // All outputs are static
            // Merge them into a single static list
            let allElements: [any ViewListElements] = outputsList.compactMap { output in
                guard case .staticList(let elements) = output.views else { return nil }
                return elements
            }
            // Merge all elements
            let mergedElements: MergedElements = MergedElements(allElements)
            return .staticList(
                mergedElements,
                inputs: inputs,
                count: outputsList.reduce(0) { $0 + ($1.count ?? 0) }
            )
        }
    }
}


extension ViewListOutputs {
    enum Views {
        case staticList(any ViewListElements)
        case dynamicList(Attribute<ViewList>)
    }
}

extension ViewListOutputs: CustomStringConvertible {
    public var description: String {
        "ViewListOutputs"
    }
}
