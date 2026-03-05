//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 05/03/2026.
//

import Testing
import SwiftUI

extension String {
    func slice(_ size: Int) -> [String] {
        guard size > 0 else { return [] }

        var result: [String] = []
        var startIndex: String.Index = self.startIndex

        while startIndex < self.endIndex {
            let endIndex: String.Index = self.index(startIndex, offsetBy: size, limitedBy: self.endIndex) ?? self.endIndex
            let chunk: String = String(self[startIndex..<endIndex])
            result.append(chunk)
            startIndex = endIndex
        }

        return result
    }
}

struct ViewInputs {
    let position: CGPoint
    let size: CGSize
}

struct ViewOutputs {
    let layoutComputer: LayoutComputer
    let displayList: DisplayList
}

struct ViewListOutputs {
    let viewList: any ViewList

    init(viewList: any ViewList) {
        self.viewList = viewList
    }
}

struct LayoutComputer {
    let sizeThatFits: (_ proposedSize: ProposedViewSize) -> CGSize
    let viewGeometries: (_ rect: CGRect) -> [CGRect]
}

struct LayoutProxy {
    private let layoutComputer: LayoutComputer
    private let place: (CGRect) -> Void

    init(
        layoutComputer: LayoutComputer,
        place: @escaping (_ rect: CGRect) -> Void
    ) {
        self.layoutComputer = layoutComputer
        self.place = place
    }

    func size(in proposal: ProposedViewSize) -> CGSize {
        layoutComputer.sizeThatFits(proposal)
    }

    func place(in rect: CGRect) {
        place(rect)
    }
}

protocol Layout {
    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: [LayoutProxy]
    ) -> CGSize

    func placeSubviews(
        in bounds: CGRect,
        subviews: [LayoutProxy]
    )
}

extension Layout {
    func layoutComputer(for subviews: [LayoutComputer]) -> LayoutComputer {
        var geometries: [CGRect] = Array(repeating: .zero, count: subviews.count)
        let proxies: [LayoutProxy] = subviews.enumerated().map { index, computer in
            LayoutProxy(layoutComputer: computer) { rect in
                geometries[index] = rect
            }
        }

        return LayoutComputer { proposal in
            sizeThatFits(proposal: proposal, subviews: proxies)
        } viewGeometries: { rect in
            placeSubviews(in: rect, subviews: proxies)
            return geometries
        }
    }
}

protocol View {
    static func makeView(_ view: Self, inputs: ViewInputs) -> ViewOutputs
    static func makeViewList(_ view: Self) -> ViewListOutputs
}

struct Text: View {
    private let text: String

    init(_ text: String) {
        self.text = text
    }

    static func makeView(_ view: Text, inputs: ViewInputs) -> ViewOutputs {
        let layoutComputer = LayoutComputer { proposedSize in
            let lines: [String] = if let proposedWidth = proposedSize.width {
                view.text.slice(Int(proposedWidth))
            } else {
                [view.text]
            }
            let maxWidth = lines.map { $0.count }.max() ?? 0
            return CGSize(
                width: CGFloat(maxWidth),
                height: CGFloat(lines.count)
            )
        } viewGeometries: { rect in
            [rect]
        }

        let makeDisplayList = {
            let textGeometries = layoutComputer.viewGeometries(CGRect(origin: .zero, size: inputs.size))
            let textGeometry = textGeometries[0]
            let lines: [String] = view.text.slice(Int(textGeometry.width))
            return DisplayList(
                lines.enumerated().map { index, line in
                        .command(
                            PutLineCommand(
                                text: line,
                                position: CGPoint(x: 0, y: inputs.position.y + CGFloat(index))
                            )
                        )
                }
            )
        }

        return .init(
            layoutComputer: layoutComputer,
            displayList: makeDisplayList()
        )
    }

    static func makeViewList(_ view: Text) -> ViewListOutputs {
        let element = UnaryViewElement { inputs in
            Self.makeView(view, inputs: inputs)
        }
        let viewList = BaseViewList(elements: [element])
        return .init(viewList: viewList)
    }
}

protocol ViewList {
    typealias MakeViewOutputs = (ViewInputs) -> ViewOutputs

    func makeViewOutputs(
        inputs: ViewInputs,
        makeViewOutputs: (_ inputs: ViewInputs, _ makeViewOutputs: MakeViewOutputs) -> ViewOutputs?
    ) -> [ViewOutputs]
}

extension ViewList {
    func makeViewOutputs(inputs: ViewInputs) -> [ViewOutputs] {
        makeViewOutputs(inputs: inputs) { inputs, makeViewOutputs in
            makeViewOutputs(inputs)
        }
    }
}

protocol ViewElement {
    typealias MakeViewOutputs = (ViewInputs) -> ViewOutputs

    func makeViewOutputs(
        inputs: ViewInputs,
        makeViewOutputs: (_ inputs: ViewInputs, _ makeViewOutputs: MakeViewOutputs) -> ViewOutputs?
    ) -> ViewOutputs?
}

struct BaseViewList: ViewList {
    private let elements: [any ViewElement]

    init(elements: [any ViewElement]) {
        self.elements = elements
    }

    func makeViewOutputs(
        inputs: ViewInputs,
        makeViewOutputs: (_ inputs: ViewInputs, _ makeViewOutputs: MakeViewOutputs) -> ViewOutputs?
    ) -> [ViewOutputs] {
        withoutActuallyEscaping(makeViewOutputs) { escapingMakeViewOutputs in
            elements.compactMap { element in
                element.makeViewOutputs(inputs: inputs) { inputs, makeViewOutputs in
                    escapingMakeViewOutputs(inputs, makeViewOutputs)
                }
            }
        }
    }
}

struct MergedViewList: ViewList {
    private let viewLists: [any ViewList]

    init(viewLists: [any ViewList]) {
        self.viewLists = viewLists
    }

    func makeViewOutputs(
        inputs: ViewInputs,
        makeViewOutputs: (_ inputs: ViewInputs, _ makeViewOutputs: MakeViewOutputs) -> ViewOutputs?
    ) -> [ViewOutputs] {
        withoutActuallyEscaping(makeViewOutputs) { escapingMakeViewOutputs in
            viewLists.flatMap { viewList in
                viewList.makeViewOutputs(inputs: inputs, makeViewOutputs: escapingMakeViewOutputs)
            }
        }
    }
}

struct UnaryViewElement: ViewElement {
    private let makeOutputs: (ViewInputs) -> ViewOutputs

    init(makeOutputs: @escaping (ViewInputs) -> ViewOutputs) {
        self.makeOutputs = makeOutputs
    }

    func makeViewOutputs(
        inputs: ViewInputs,
        makeViewOutputs: (_ inputs: ViewInputs, _ makeViewOutputs: MakeViewOutputs) -> ViewOutputs?
    ) -> ViewOutputs? {
        withoutActuallyEscaping(makeViewOutputs) { escapingMakeViewOutputs in
            escapingMakeViewOutputs(inputs, makeOutputs)
        }
    }
}

struct PutLineCommand {
    let text: String
    let position: CGPoint
}

struct DisplayList {
    enum Item {
        case command(PutLineCommand)
        case childList(DisplayList)
    }

    let items: [Item]

    init(_ items: [Item]) {
        self.items = items
    }
}

// --------------------------------------

struct TupleView<each V: View>: View {
    private let childViews: (repeat each V)

    init(_ childViews: repeat each V) {
        self.childViews = (repeat each childViews)
    }

    static func makeView(_ view: Self, inputs: ViewInputs) -> ViewOutputs {
        fatalError("Not implemented")
    }

    static func makeViewList(_ view: Self) -> ViewListOutputs {
        var viewListOutputs: [ViewListOutputs] = []
        for childView in repeat each view.childViews {
            let childOutputs = type(of: childView).makeViewList(childView)
            viewListOutputs.append(childOutputs)
        }

        let viewLists: [any ViewList] = viewListOutputs.map(\.viewList)
        let viewList = MergedViewList(viewLists: viewLists)
        return .init(viewList: viewList)
    }
}

struct VStackLayout: Layout {
    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: [LayoutProxy]
    ) -> CGSize {
        let frames = viewFrames(proposal: proposal, subviews: subviews)
        var totalHeight: CGFloat = 0
        var maxWidth: CGFloat = 0

        for frame in frames {
            totalHeight += frame.height
            maxWidth = max(maxWidth, frame.width)
        }

        return CGSize(width: maxWidth, height: totalHeight)
    }

    func placeSubviews(
        in bounds: CGRect,
        subviews: [LayoutProxy]
    ) {
        let frames = viewFrames(
            proposal: ProposedViewSize(bounds.size),
            subviews: subviews
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(in: frames[index])
        }
    }

    private func viewFrames(
        proposal: ProposedViewSize,
        subviews: [LayoutProxy]
    ) -> [CGRect] {
        var frames: [CGRect] = []
        var yPosition: CGFloat = 0

        for subview in subviews {
            let subviewSize = subview.size(in: proposal)
            let frame = CGRect(
                x: 0,
                y: yPosition,
                width: subviewSize.width,
                height: subviewSize.height
            )
            frames.append(frame)
            yPosition += subviewSize.height
        }

        return frames
    }
}

struct VStack<Content: View>: View {
    private let content: Content

    init(_ content: Content) {
        self.content = content
    }

    static func makeView(_ view: VStack, inputs: ViewInputs) -> ViewOutputs {
        let childViewListOutputs: ViewListOutputs = Content.makeViewList(view.content)

        // First pass: collect layout computers using the proposed size.
        // We need all of them before we can compute any child geometry.
        var childLayoutComputers: [LayoutComputer] = childViewListOutputs.viewList
            .makeViewOutputs(inputs: inputs)
            .map(\.layoutComputer)

        // Compute layout geometry for every child at once.
        let layout = VStackLayout()
        let layoutComputer = layout.layoutComputer(for: childLayoutComputers)
        let proposal = ProposedViewSize(inputs.size)
        let containerSize = layoutComputer.sizeThatFits(proposal)
        let childGeometries = layoutComputer.viewGeometries(CGRect(origin: .zero, size: containerSize))

        // Second pass: generate final outputs with correct positions and sizes.
        var index = 0
        let childViewOutputs = childViewListOutputs.viewList.makeViewOutputs(inputs: inputs) { _, makeViewOutputs in
            let childGeometry = childGeometries[index]
            let modifiedInputs = ViewInputs(position: childGeometry.origin, size: childGeometry.size)
            index += 1
            return makeViewOutputs(modifiedInputs)
        }

        let displayList = DisplayList(
            childViewOutputs.map(\.displayList).map { .childList($0) }
        )

        return .init(layoutComputer: layoutComputer, displayList: displayList)
    }

    static func makeViewList(_ view: VStack<Content>) -> ViewListOutputs {
        Content.makeViewList(view.content)
    }
}

@Test
func main() {
    let inputs = ViewInputs(
        position: .zero,
        size: .init(
            width: 2,
            height: 20
        )
    )
    let view = VStack(
        TupleView(
            Text("He"),
            Text("ll")
        )
    )
    print(type(of: view).makeView(view, inputs: inputs))
}
