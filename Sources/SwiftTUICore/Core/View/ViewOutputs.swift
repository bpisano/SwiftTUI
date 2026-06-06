//
//  ViewOutputs.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 10/03/2026.
//

import Foundation
import Geometry
import AttributeGraph

@_documentation(visibility: internal)
public struct ViewOutputs: Sendable {
    public let displayList: Attribute<DisplayList>
    public let focusList: Attribute<FocusList>?

    let viewId: ViewId
    let layoutComputer: Attribute<LayoutComputer>

    init(
        viewId: ViewId = ViewId(implicitId: -1),
        layoutComputer: Attribute<LayoutComputer>,
        displayList: Attribute<DisplayList>,
        focusList: Attribute<FocusList>? = nil
    ) {
        self.viewId = viewId
        self.layoutComputer = layoutComputer
        self.displayList = displayList
        self.focusList = focusList
    }

    func withViewId(_ viewId: ViewId) -> ViewOutputs {
        ViewOutputs(
            viewId: viewId,
            layoutComputer: layoutComputer,
            displayList: displayList,
            focusList: focusList
        )
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

    @MainActor
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

        let combinedFocusList: Attribute<FocusList>? = combineFocusLists(viewOutputs)

        return ViewOutputs(
            layoutComputer: combinedLayoutComputer,
            displayList: combinedDisplayList,
            focusList: combinedFocusList
        )
    }

    /// Combines a *reactive* set of child outputs into a single `ViewOutputs`.
    ///
    /// The child outputs are read from `container` on every evaluation, gated by
    /// `info` so that a dynamic child list which changes shape (for example a
    /// conditional switching branches) is reflected in the combined output. The
    /// container materializes each child once and reuses it by identity, so this
    /// does not rebuild — or leak — child attributes on every re-render.
    @MainActor
    static func combineViewOutputs(
        container: RetainedUnaryContainer,
        info: Attribute<Int>
    ) -> ViewOutputs {
        final class SizeCache {
            var lastWidth: GeometryUnit = .nan
            var childSizes: [Size] = []
        }
        let sizeCache = SizeCache()

        let combinedLayoutComputer = Attribute("Unary LayoutComputer") {
            _ = info.wrappedValue
            let computers = container.orderedOutputs.map { $0.layoutComputer.wrappedValue }

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

                sizeCache.lastWidth = proposal.width ?? .nan
                sizeCache.childSizes = sizes

                return Size(width: maxWidth, height: totalHeight)
            } viewGeometries: { [sizeCache] rect in
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

        let combinedDisplayList = Attribute("Unary DisplayList") {
            _ = info.wrappedValue
            var items = [DisplayList.Item]()
            for output in container.orderedOutputs {
                items.append(contentsOf: output.displayList.wrappedValue.items)
            }
            return DisplayList(items)
        }

        let combinedFocusList = Attribute("Unary FocusList") {
            _ = info.wrappedValue
            let lists = container.orderedOutputs.compactMap { $0.focusList?.wrappedValue }
            return FocusList.concat(lists)
        }

        return ViewOutputs(
            layoutComputer: combinedLayoutComputer,
            displayList: combinedDisplayList,
            focusList: combinedFocusList
        )
    }

    @MainActor
    static func combineFocusLists(_ viewOutputs: [ViewOutputs]) -> Attribute<FocusList>? {
        let focusListAttributes: [Attribute<FocusList>] = viewOutputs.compactMap(\.focusList)
        guard !focusListAttributes.isEmpty else { return nil }
        if focusListAttributes.count == 1 {
            return focusListAttributes[0]
        }
        return Attribute("Combined FocusList") {
            FocusList.concat(focusListAttributes.map(\.wrappedValue))
        }
    }
}

/// Retains the materialized outputs of a unary modifier's child list.
///
/// A unary modifier (`.disabled`, `.foregroundStyle`, …) wraps a child list that
/// may be dynamic — most importantly a conditional whose branch changes at
/// runtime. This container materializes each child item once, reuses it by
/// identity across re-renders, and cleans the subgraph of any item that goes
/// away. That keeps the modifier reactive to structural changes without
/// re-materializing (and leaking) child attributes on every evaluation.
@MainActor
final class RetainedUnaryContainer {
    private struct Entry {
        let identity: AnyHashable
        let viewIds: [ViewId]
        let outputs: [ViewOutputs]
        let subgraph: Subgraph

        @MainActor
        func clean() {
            subgraph.clean()
        }
    }

    private var entriesByIdentity: [AnyHashable: Entry] = [:]
    private var orderedEntries: [Entry] = []

    var orderedOutputs: [ViewOutputs] {
        orderedEntries.flatMap(\.outputs)
    }

    func update(from viewList: any ViewList, inputs: ViewInputs) {
        var nextEntriesByIdentity: [AnyHashable: Entry] = [:]
        var nextOrderedEntries: [Entry] = []

        viewList.applyItems { item in
            let entry: Entry

            if let existing = entriesByIdentity.removeValue(forKey: item.identity),
               existing.viewIds == item.viewIds {
                entry = existing
            } else {
                entry = makeEntry(from: item, inputs: inputs)
            }

            nextEntriesByIdentity[item.identity] = entry
            nextOrderedEntries.append(entry)
        }

        for removedEntry in entriesByIdentity.values {
            removedEntry.clean()
        }

        entriesByIdentity = nextEntriesByIdentity
        orderedEntries = nextOrderedEntries
    }

    private func makeEntry(
        from item: RetainedViewListItem,
        inputs: ViewInputs
    ) -> Entry {
        let subgraph = Subgraph()

        let outputs = subgraph.withDependencyCapture {
            var startIndex = 0
            return item.makeViewOutputs(
                startIndex: &startIndex,
                inputs: inputs
            ) { _, viewId, childInputs, makeViewOutputs in
                makeViewOutputs(childInputs).withViewId(viewId)
            }
        }

        return Entry(
            identity: item.identity,
            viewIds: item.viewIds,
            outputs: outputs,
            subgraph: subgraph
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
