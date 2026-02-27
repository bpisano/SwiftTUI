//
//  ViewOutputs.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 20/11/2025.
//

import Foundation
import AttributeGraph
import Geometry

public struct ViewOutputs {
    public let layoutComputer: Attribute<LayoutComputer>
    public let displayList: Attribute<DisplayList>

    init(
        layoutComputer: Attribute<LayoutComputer>,
        displayList: Attribute<DisplayList>
    ) {
        self.layoutComputer = layoutComputer
        self.displayList = displayList
    }

    init() {
        self.layoutComputer = Attribute {
            LayoutComputer { proposal in
                return .zero
            } childGeometries: { rect in
                []
            }
        }
        self.displayList = Attribute {
            DisplayList([])
        }
    }
}

extension ViewOutputs {
    static func multiView(
        inputs: ViewInputs,
        body: (ViewListInputs) -> ViewListOutputs
    ) -> ViewOutputs {
        let listInputs: ViewListInputs = .init(from: inputs)
        let listOutputs: ViewListOutputs = body(listInputs)
        let childOutputs: [ViewOutputs] = listOutputs.materializeChildren(inputs: inputs)
        return combineChildren(childOutputs)
    }

    private static func combineChildren(_ childOutputs: [ViewOutputs]) -> ViewOutputs {
        guard !childOutputs.isEmpty else {
            return ViewOutputs()
        }

        let combinedLayoutComputer = Attribute {
            LayoutComputer { proposal in
                let childSizes: [Size] = childOutputs.map {
                    $0.layoutComputer.wrappedValue.sizeThatFits(proposal)
                }
                let totalHeight: Double = childSizes.reduce(0.0) { $0 + $1.height }
                let maxWidth: Double = childSizes.map(\.width).max() ?? 0
                return .init(width: maxWidth, height: totalHeight)
            } childGeometries: { rect in
                var currentY: Double = rect.origin.y
                return childOutputs.enumerated().flatMap { index, output in
                    let childSize: Size = output.layoutComputer.wrappedValue.sizeThatFits(
                        .init(width: rect.size.width, height: nil)
                    )
                    let childRect: Rect = .init(
                        origin: Point(x: rect.origin.x, y: currentY),
                        size: childSize
                    )
                    currentY += childSize.height
                    return output.layoutComputer.wrappedValue.childGeometries(in: childRect)
                }
            }
        }

        let combinedDisplayList = Attribute {
            DisplayList(childOutputs.flatMap { $0.displayList.wrappedValue.items })
        }

        return ViewOutputs(
            layoutComputer: combinedLayoutComputer,
            displayList: combinedDisplayList
        )
    }
}

private extension ViewListOutputs {
    func materializeChildren(inputs: ViewInputs) -> [ViewOutputs] {
        switch views {
        case .staticList(let elements):
            return materializeStaticElements(elements, inputs: inputs)
        case .dynamicList(let listAttribute):
            let list = listAttribute.wrappedValue
            return materializeDynamicList(list, inputs: inputs)
        }
    }

    private func materializeStaticElements(
        _ elements: any ViewListElements,
        inputs: ViewInputs
    ) -> [ViewOutputs] {
        var results: [ViewOutputs] = []
        var start = 0

        _ = elements.makeElements(from: &start, inputs: inputs) { index, elementInputs, makeElement in
            let output = makeElement(elementInputs)
            results.append(output)
            return (output, true)
        }

        return results
    }

    private func materializeDynamicList(
        _ list: ViewList,
        inputs: ViewInputs
    ) -> [ViewOutputs] {
        var results: [ViewOutputs] = []
        var start = 0

        list.makeViews(from: &start, inputs: inputs) { index, elementInputs, makeElement in
            let output = makeElement(elementInputs)
            results.append(output)
            return (output, true)
        }

        return results
    }
}

