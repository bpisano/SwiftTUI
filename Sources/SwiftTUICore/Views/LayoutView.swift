//
//  File.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 16/03/2026.
//

import Foundation
import AttributeGraph
import Geometry

struct LayoutView<L: Layout, Content: View>: View, PrimitiveView {
    private let layout: L
    private let content: Content

    init(
        layout: L,
        content: Content
    ) {
        self.layout = layout
        self.content = content
    }
}

extension LayoutView {
    static func makeView(
        _ view: Attribute<Self>,
        inputs: ViewInputs
    ) -> ViewOutputs {
        var childGeometries: Attribute<[ViewGeometry]>!
        var containerInfo: Attribute<[ViewId: Int]>!
        var engine: LayoutEngine<L>?
        let container = RetainedLayoutContainer(labelPrefix: "\(Content.self)")

        let contentAttribute: Attribute<Content> = view.map(\.content)
        let viewListInputs: ViewListInputs = .init(viewInputs: inputs)
        let contentViewListOutputs: ViewListOutputs = Content.makeViewList(
            contentAttribute,
            inputs: viewListInputs
        )
        let contentViewList: Attribute<any ViewList> = contentViewListOutputs.makeViewListAttribute(
            "\(Content.self) Child ViewList"
        )

        let layoutComputer = Attribute("\(Content.self) LayoutComputer") {
            _ = containerInfo.wrappedValue

            let layout: L = view.wrappedValue.layout
            let childAttributes: [Attribute<LayoutComputer>] = container.orderedOutputs
                .map(\.layoutComputer)

            if let existing = engine {
                existing.update(layout: layout, subviewAttributes: childAttributes)
            } else {
                engine = LayoutEngine(layout: layout, subviewAttributes: childAttributes)
            }

            return engine!.makeLayoutComputer()
        }

        let displayList = Attribute("\(Content.self) DisplayList") {
            _ = containerInfo.wrappedValue
            _ = childGeometries.wrappedValue

            return DisplayList(
                container.orderedOutputs
                    .map { .childList($0.displayList.wrappedValue) }
            )
        }

        childGeometries = Attribute("\(Content.self) Child Geometries") {
            let proposal: ProposedViewSize = .init(inputs.size.wrappedValue)
            let containerSize: Size = layoutComputer.wrappedValue.sizeThatFits(proposal)
            return layoutComputer.wrappedValue.viewGeometries(
                Rect(
                    origin: inputs.position.wrappedValue,
                    size: containerSize
                )
            )
        }

        containerInfo = Attribute("\(Content.self) ContainerInfo") {
            container.update(
                from: contentViewList.wrappedValue,
                inputs: inputs,
                containerInfo: containerInfo,
                childGeometries: childGeometries
            )
        }

        return .init(
            layoutComputer: layoutComputer,
            displayList: displayList
        )
    }

    static func makeViewList(
        _ view: Attribute<Self>,
        inputs: ViewListInputs
    ) -> ViewListOutputs {
        .unaryViewListOutputs("\(Content.self) ViewList", implicitId: inputs.implicitId) { inputs in
            Self.makeView(view, inputs: inputs)
        }
    }
}

extension LayoutView: @MainActor AttributeValueRepresentable {
    var attributeValueDescription: String {
        "LayoutView"
    }
}

@MainActor
private final class RetainedLayoutContainer {
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

    private let labelPrefix: String

    private var entriesByIdentity: [AnyHashable: Entry] = [:]
    private var orderedEntries: [Entry] = []

    init(labelPrefix: String) {
        self.labelPrefix = labelPrefix
    }

    var orderedOutputs: [ViewOutputs] {
        orderedEntries.flatMap(\.outputs)
    }

    func update(
        from viewList: any ViewList,
        inputs: ViewInputs,
        containerInfo: Attribute<[ViewId: Int]>,
        childGeometries: Attribute<[ViewGeometry]>
    ) -> [ViewId: Int] {
        var nextEntriesByIdentity: [AnyHashable: Entry] = [:]
        var nextOrderedEntries: [Entry] = []

        viewList.applyItems { item in
            let entry: Entry

            if let existing = entriesByIdentity.removeValue(forKey: item.identity),
               existing.viewIds == item.viewIds {
                entry = existing
            } else {
                entry = makeEntry(
                    from: item,
                    inputs: inputs,
                    containerInfo: containerInfo,
                    childGeometries: childGeometries
                )
            }

            nextEntriesByIdentity[item.identity] = entry
            nextOrderedEntries.append(entry)
        }

        for removedEntry in entriesByIdentity.values {
            removedEntry.clean()
        }

        entriesByIdentity = nextEntriesByIdentity
        orderedEntries = nextOrderedEntries

        return makeIndexMap()
    }

    private func makeIndexMap() -> [ViewId: Int] {
        var map: [ViewId: Int] = [:]
        var index = 0

        for entry in orderedEntries {
            for viewId in entry.viewIds {
                map[viewId] = index
                index += 1
            }
        }

        return map
    }

    private func makeEntry(
        from item: RetainedViewListItem,
        inputs: ViewInputs,
        containerInfo: Attribute<[ViewId: Int]>,
        childGeometries: Attribute<[ViewGeometry]>
    ) -> Entry {
        let subgraph = Subgraph()

        let outputs = subgraph.withDependencyCapture {
            let viewIds = item.viewIds
            var localStartIndex = 0
            var leafIndex = 0

            let outputs = item.makeViewOutputs(
                startIndex: &localStartIndex,
                inputs: inputs
            ) { [self] _, viewId, childInputs, makeViewOutputs in
                let stableId =
                    if leafIndex < viewIds.count {
                        viewIds[leafIndex]
                    } else {
                        viewId
                    }
                leafIndex += 1

                let childGeometry = Attribute("\(self.labelPrefix) Child Geometry \(stableId)") {
                    guard let index = containerInfo.wrappedValue[stableId] else {
                        return ViewGeometry.zero
                    }

                    let geometries = childGeometries.wrappedValue
                    guard index < geometries.count else {
                        return ViewGeometry.zero
                    }

                    return geometries[index]
                }

                let modifiedInputs = ViewInputs(
                    position: childGeometry.map(\.origin),
                    size: childGeometry.map(\.size),
                    phase: childInputs.phase,
                    environment: childInputs.environment,
                    storage: childInputs.storage
                )

                let rawOutputs = makeViewOutputs(modifiedInputs)
                return rawOutputs.withViewId(stableId)
            }

            precondition(
                outputs.count == viewIds.count,
                "Retained layout item produced \(outputs.count) outputs for \(viewIds.count) ids."
            )

            return outputs
        }

        return Entry(
            identity: item.identity,
            viewIds: item.viewIds,
            outputs: outputs,
            subgraph: subgraph
        )
    }
}
