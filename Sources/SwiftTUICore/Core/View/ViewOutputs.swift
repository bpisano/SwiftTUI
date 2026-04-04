//
//  ViewOutputs.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 10/03/2026.
//

import Foundation
import Geometry
import AttributeGraph

public struct ViewOutputs: Sendable {
    public let displayList: Attribute<DisplayList>

    let layoutComputer: Attribute<LayoutComputer>

    init(
        layoutComputer: Attribute<LayoutComputer>,
        displayList: Attribute<DisplayList>
    ) {
        self.layoutComputer = layoutComputer
        self.displayList = displayList
    }
}

extension ViewOutputs {
    /// Creates `ViewOutputs` for a view that contains multiple child views, by combining the outputs of its children.
    ///
    /// - Parameters:
    ///   - inputs: The `ViewInputs` for the parent view.
    ///   - makeViewListOutputs: A closure that takes `ViewListInputs` and returns `ViewListOutputs` for the child views.
    ///   - Returns: A `ViewOutputs` instance that combines the outputs of the child views.
    @MainActor
    static func unaryViewOutputs(
        inputs: ViewInputs,
        makeViewListOutputs: (ViewListInputs) -> ViewListOutputs,
    ) -> ViewOutputs {
        let viewListInputs: ViewListInputs = .init(viewInputs: inputs)
        let viewListOutputs: ViewListOutputs = makeViewListOutputs(viewListInputs)
        return viewListOutputs.makeUnaryViewOutputs(inputs: inputs)
    }

    static func combineViewOutputs(_ viewOutputs: [ViewOutputs]) -> ViewOutputs {
        guard !viewOutputs.isEmpty else {
            fatalError("Cannot combine an empty array of ViewOutputs")
        }

        // Shared cache: stores the child sizes from the last sizeThatFits call.
        // `viewGeometries` reuses them when the proposal width matches, avoiding
        // a redundant second round of sizeThatFits calls.
        final class SizeCache {
            var lastWidth: GeometryUnit = .nan
            var childSizes: [Size] = []
        }
        let sizeCache = SizeCache()

        let combinedLayoutComputer = Attribute {
            // Resolve child LayoutComputers once per attribute invalidation,
            // inside the Attribute rule body where dependency registration occurs.
            // This avoids repeated graph traversal on every sizeThatFits / viewGeometries call.
            let computers = viewOutputs.map { $0.layoutComputer.wrappedValue }

            return LayoutComputer { [sizeCache] proposal in
                var totalHeight: GeometryUnit = 0
                var maxWidth: GeometryUnit = 0
                var sizes = [Size](repeating: .zero, count: computers.count)

                for i in 0..<computers.count {
                    let size = computers[i].sizeThatFits(proposal)
                    sizes[i] = size
                    totalHeight += size.height
                    if size.width > maxWidth { maxWidth = size.width }
                }

                // Cache for potential reuse in viewGeometries when
                // the available width matches.
                sizeCache.lastWidth = proposal.width ?? .nan
                sizeCache.childSizes = sizes

                return Size(width: maxWidth, height: totalHeight)
            } viewGeometries: { [sizeCache] rect in
                // Reuse sizes from the last sizeThatFits if the width matches —
                // viewGeometries always proposes (width, nil) to children, so
                // width is the only variable that matters for cache validity.
                let childSizes: [Size]
                if rect.width == sizeCache.lastWidth,
                   sizeCache.childSizes.count == computers.count {
                    childSizes = sizeCache.childSizes
                } else {
                    let proposal = ProposedViewSize(width: rect.width, height: nil)
                    var sizes = [Size](repeating: .zero, count: computers.count)
                    for i in 0..<computers.count {
                        sizes[i] = computers[i].sizeThatFits(proposal)
                    }
                    childSizes = sizes
                }

                var currentY = rect.origin.y
                var geometries = [ViewGeometry]()
                geometries.reserveCapacity(computers.count)

                for i in 0..<computers.count {
                    let childRect = Rect(
                        origin: Point(x: rect.origin.x, y: currentY),
                        size: childSizes[i]
                    )
                    currentY += childSizes[i].height
                    geometries.append(contentsOf: computers[i].viewGeometries(childRect))
                }
                return geometries
            }
        }

        let combinedDisplayList = Attribute {
            var items = [DisplayList.Item]()
            items.reserveCapacity(viewOutputs.count)
            for output in viewOutputs {
                items.append(contentsOf: output.displayList.wrappedValue.items)
            }
            return DisplayList(items)
        }

        return ViewOutputs(
            layoutComputer: combinedLayoutComputer,
            displayList: combinedDisplayList
        )
    }
}

extension ViewOutputs: AttributeValueRepresentable {
    public var attributeValueDescription: String {
        "ViewOutputs"
    }
}

extension Array: AttributeValueRepresentable where Element == ViewOutputs {
    public var attributeValueDescription: String {
        "Array of \(count) ViewOutputs"
    }
}
