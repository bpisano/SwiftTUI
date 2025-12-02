//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 25/11/2025.
//

import AttributeGraph
import Foundation

struct ViewListOutputs {
    let views: Views
    let count: Int? = nil

    init(views: Views) {
        self.views = views
    }

    func makeViewList() -> ViewList {
        switch views {
        case .staticList(let elements):
            BaseViewList(elements: elements)
        case .dynamicList(let list):
            list.wrappedValue
        }
    }
}

extension ViewListOutputs {
    static func staticList(_ elements: any ViewListElements) -> ViewListOutputs {
        ViewListOutputs(
            views: .staticList(elements)
        )
    }

    static func dynamicList(_ list: Attribute<ViewList>) -> ViewListOutputs {
        ViewListOutputs(
            views: .dynamicList(list)
        )
    }

    static func single<V: View>(_ view: Attribute<V>) -> ViewListOutputs {
        .staticList(SingleElement(view))
    }

    static func concat(_ outputsList: [ViewListOutputs]) -> ViewListOutputs {
        guard !outputsList.isEmpty else {
            return .staticList(EmptyElement())
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
            return .dynamicList(mergedListAttribute)
        } else {
            // All outputs are static
            // Merge them into a single static list
            let allElements: [any ViewListElements] = outputsList.compactMap { output in
                guard case .staticList(let elements) = output.views else { return nil }
                return elements
            }
            // Merge all elements
            let mergedElements: MergedElements = MergedElements(allElements)
            return .staticList(mergedElements)
        }
    }
}

extension ViewListOutputs {
    enum Views {
        case staticList(any ViewListElements)
        case dynamicList(Attribute<ViewList>)
    }
}

//extension ViewListOutputs {
//    static func single<V: View>(_ view: Attribute<V>) -> ViewListOutputs {
//        ViewListOutputs(
//            elements: [ViewElement(view)],
//            count: 1
//        )
//    }
//
//    static func concat(_ lists: [ViewListOutputs]) -> ViewListOutputs {
//        let allElements: [AnyViewElement] = lists.flatMap { $0.elements }
//        let totalCount: Int = lists.compactMap { $0.count }.reduce(0, +)
//
//        return ViewListOutputs(
//            elements: allElements,
//            count: lists.allSatisfy { $0.count != nil } ? totalCount : nil
//        )
//    }
//
//    static var empty: ViewListOutputs {
//        ViewListOutputs(elements: [], count: 0)
//    }
//}

extension ViewListOutputs: CustomStringConvertible {
    var description: String {
        "ViewListOutputs"
    }
}
