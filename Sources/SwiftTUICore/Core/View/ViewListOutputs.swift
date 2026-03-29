//
//  ViewListOutputs.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 10/03/2026.
//

import Foundation
import AttributeGraph

public struct ViewListOutputs {
    let views: Views

    init(views: Views) {
        self.views = views
    }

    func makeViewListAttribute(_ label: String = "ViewList") -> Attribute<any ViewList> {
        switch views {
        case let .staticList(viewElements):
            Attribute(label) {
                BaseViewList(elements: viewElements)
            }
        case let .dynamicList(viewListAttribute):
            viewListAttribute
        }
    }
}

extension ViewListOutputs {
    enum Views {
        case staticList([any ViewElement])
        case dynamicList(Attribute<any ViewList>)
    }
}

// MARK: - ViewListOutputs instance creation helpers

extension ViewListOutputs {
    /// Creates an empty `ViewListOutputs` instance, which represents a view list with no child views.
    /// This is useful for views that do not have any child views, allowing them to return an empty view list output instead of needing to create a static list with an empty element.
    ///
    /// - Returns: An empty `ViewListOutputs` instance.
    static func empty() -> ViewListOutputs {
        .init(views: .staticList([EmptyViewElement()]))
    }

    /// Creates a `ViewListOutputs` containing a single view generated from the provided closure.
    /// This is useful for creating a view list output for a view that only has one child view, without needing to create a static list with a single element.
    ///
    /// - Parameters:
    ///   - label: An optional label for the view list attribute. Defaults to "ViewList".
    ///   - makeViewOutputs: A closure that takes `ViewInputs` and returns `ViewOutputs` for the unary view list.
    /// - Returns: A `ViewListOutputs` instance containing a single view generated from the provided closure.
    static func unaryViewListOutputs(
        _ label: String = "ViewList",
        makeViewOutputs: @escaping (ViewInputs) -> ViewOutputs
    ) -> ViewListOutputs {
        let unaryViewElement: UnaryViewElement = .init(makeOutputs: makeViewOutputs)
        return .init(views: .staticList([unaryViewElement]))
    }

    /// Concatenates multiple `ViewListOutputs` into a single `ViewListOutputs` instance.
    /// This function optimizes the concatenation by merging consecutive static lists into a single static list, and only creating dynamic lists when necessary.
    ///
    /// Example:
    /// Given the following view list outputs:
    /// ```
    /// [
    ///     staticList([A]),
    ///     staticList([B, C]),
    ///     dynamicList(X),
    ///     staticList([D])
    /// ]
    /// ```
    /// The concatenated output will be:
    /// ```
    /// .dynamicList(
    ///     MergedViewList(viewLists: [
    ///         Attribute(BaseViewList([A, B, C])),
    ///         X,
    ///         Attribute(BaseViewList([D]))
    ///     ])
    /// )
    /// ```
    ///
    /// - Parameters:
    ///   - viewListOutputs: An array of `ViewListOutputs` to concatenate.
    ///   - label: An optional label for the merged view list attribute. Defaults to "Concatenated ViewList".
    /// - Returns: A single `ViewListOutputs` instance that represents the concatenation of all the input view list outputs.
    static func concat(
        _ viewListOutputs: [ViewListOutputs],
        label: String = "Concatenated ViewList"
    ) -> ViewListOutputs {
        // Helper function to merge static elements from a range of view list outputs.
        //
        // Example:
        // outputs[0] = staticList([A])
        // outputs[1] = staticList([B, C])
        // mergedStaticElements(0, 2) => [A, B, C]
        func mergedStaticElements(
            from start: Int,
            to end: Int
        ) -> [any ViewElement] {
            viewListOutputs[start..<end].flatMap { output in
                guard case let .staticList(elements) = output.views else {
                    preconditionFailure("Expected only static outputs. Found a dynamic output at index \(start..<end).")
                }
                return elements
            }
        }

        // Helper function to create a static view list attribute from a range of view list outputs.
        //
        // Example:
        // [static(A), static(B), dynamic(X), static(C)]
        // Becomes:
        // [Attribute(BaseViewList([A, B])), X, Attribute(BaseViewList([C]))]
        func makeStaticViewListAttribute(
            from start: Int,
            to end: Int
        ) -> Attribute<any ViewList> {
            let elements = mergedStaticElements(from: start, to: end)
            return Attribute("Static Run ViewList") {
                BaseViewList(elements: elements)
            }
        }

        // Check if all view list outputs are empty.
        // If they are, we can return a single empty view list output instead of concatenating them.
        guard !viewListOutputs.isEmpty else {
            return .empty()
        }

        // Check if all elements are statics lists.
        let allStatic: Bool = viewListOutputs.allSatisfy { output in
            if case .staticList = output.views {
                return true
            }
            return false
        }

        // If all elements are static lists, we can concatenate them into a single static list output.
        if allStatic {
            let staticElements: [any ViewElement] = mergedStaticElements(
                from: 0,
                to: viewListOutputs.count
            )
            return .init(
                views: .staticList(staticElements)
            )
        }

        var mergedLists: [Attribute<any ViewList>] = []
        var staticRunStart: Int = 0

        for (index, output) in viewListOutputs.enumerated() {
            guard case let .dynamicList(viewListAttribute) = output.views else {
                // While the view list encountered is static, we keep track of the start index of the run of static outputs.
                continue
            }

            // When we encounter a dynamic output, we first check if there was a run of static outputs before it.
            // If there was, we merge that run of static outputs into a single static view list attribute and add it to the merged lists.
            if staticRunStart < index {
                let staticViewList: Attribute<any ViewList> = makeStaticViewListAttribute(
                    from: staticRunStart,
                    to: index
                )
                mergedLists.append(staticViewList)
            }

            // We then add the dynamic output's view list attribute to the merged lists.
            mergedLists.append(viewListAttribute)

            // Finally, we update the start index of the next run of static outputs to be after the current index.
            staticRunStart = index + 1
        }

        // After processing all outputs, we check if there is a run of static outputs at the end that needs to be merged.
        if staticRunStart < viewListOutputs.count {
            let staticViewList: Attribute<any ViewList> = makeStaticViewListAttribute(
                from: staticRunStart,
                to: viewListOutputs.count
            )
            mergedLists.append(staticViewList)
        }

        // If there is only one merged list, we can return it directly instead of wrapping it in another merged view list.
        if mergedLists.count == 1 {
            return .init(views: .dynamicList(mergedLists[0]))
        }

        // Else we return a merged view list that concatenates all the merged lists.
        let mergedViewList: Attribute<any ViewList> = Attribute(label) {
            MergedViewList(viewLists: mergedLists)
        }
        return .init(views: .dynamicList(mergedViewList))
    }
}

// MARK: - ViewListOutputs -> [ViewOutputs]

extension ViewListOutputs {
    /// Generates an array of `ViewOutputs` from the `ViewListOutputs` instance, using the provided inputs and interceptor.
    /// The generation process depends on whether the view list outputs are static or dynamic:
    /// - For static lists, the view outputs are generated directly from the static elements without needing to go through the dynamic view list protocol.
    /// - For dynamic lists, the view outputs are generated by invoking the `makeViewOutputs` method of the dynamic view list, which allows for more complex view list outputs that may not be known at compile time.
    ///
    /// - Parameters:
    ///   - startIndex: An inout parameter that keeps track of the starting index for generating view outputs. This is used to ensure that the indices of the generated view outputs are consistent across multiple calls and can be used for optimizations or caching mechanisms.
    ///   - inputs: The `ViewInputs` to use for generating the view outputs.
    ///   - interceptor: A closure that can be used to intercept the view outputs generation process, allowing for custom behavior or modifications to the generated view outputs.
    /// - Returns: An array of `ViewOutputs` generated from the `ViewListOutputs` instance.
    func makeViewOutputs(
        startIndex: inout Int,
        inputs: ViewInputs,
        makeViewOutputs interceptor: @escaping ViewList.MakeViewOutputsInterceptor
    ) -> [ViewOutputs] {
        switch views {
        case let .staticList(elements):
            // For static lists, we can directly create the view outputs from the elements
            // without needing to go through the dynamic view list protocol.
            return BaseViewList(elements: elements).makeViewOutputs(
                startIndex: &startIndex,
                inputs: inputs,
                makeViewOutputs: interceptor
            )
        case let .dynamicList(viewList):
            // For dynamic lists, we need to go through the view list protocol to create the view outputs,
            // which allows for more complex view list outputs that may not be known at compile time.
            return viewList.wrappedValue.makeViewOutputs(
                startIndex: &startIndex,
                inputs: inputs,
                makeViewOutputs: interceptor
            )
        }
    }

    func makeViewOutputs(
        startIndex: inout Int,
        inputs: ViewInputs
    ) -> [ViewOutputs] {
        makeViewOutputs(startIndex: &startIndex, inputs: inputs) { _, inputs, makeViewOutputs in
            makeViewOutputs(inputs)
        }
    }

    func makeUnaryViewOutputs(inputs: ViewInputs) -> ViewOutputs {
        var index: Int = 0
        let childOutputs: [ViewOutputs] = makeViewOutputs(
            startIndex: &index,
            inputs: inputs
        )
        return .combineViewOutputs(childOutputs)
    }
}

// MARK: - ViewListOutputs -> Attribute<[ViewOutputs]>

extension ViewListOutputs {
    func makeViewOutputsAttribute(
        _ label: String = "ViewOutputs",
        inputs: ViewInputs,
        makeViewOutputs interceptor: @escaping ViewList.MakeViewOutputsInterceptor
    ) -> Attribute<[ViewOutputs]> {
        switch views {
        case let .staticList(elements):
            // In case of a static list, we can directly create the view outputs from the elements
            var index: Int = 0
            let viewList: BaseViewList = .init(elements: elements)
            let viewOutputs: [ViewOutputs] = viewList.makeViewOutputs(
                startIndex: &index,
                inputs: inputs,
                makeViewOutputs: interceptor
            )
            return Attribute(label) {
                viewOutputs
            }
        case let .dynamicList(viewList):
            // In case of a dynamic list, we need to go through the view list protocol to create the view outputs,
            // which allows for more complex view list outputs that may not be known at compile time.
            return Attribute(label) {
                var index: Int = 0
                return viewList.wrappedValue.makeViewOutputs(
                    startIndex: &index,
                    inputs: inputs,
                    makeViewOutputs: interceptor
                )
            }
        }
    }
}

extension ViewListOutputs: AttributeValueRepresentable {
    public var attributeValueDescription: String {
        "ViewListOutputs"
    }
}
