//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 05/03/2026.
//

import AppKit
import AttributeGraph
import SwiftUI
import Testing

/// A utility for introspecting Swift tuple types at runtime.
///
/// This struct provides access to tuple metadata stored in Swift's runtime type system.
/// It uses unsafe pointer operations to read the internal memory layout of tuple type metadata,
/// which follows a specific structure in the Swift ABI.
///
/// **Memory Layout of Tuple Metadata:**
/// - Offset 0: Kind (Int) - identifies the type as a tuple
/// - Offset 8: Number of elements (Int)
/// - Offset 16: Labels pointer (Int) - optional string labels for tuple elements
/// - Offset 24+: Array of element descriptors, each containing:
///   - Type metadata pointer (8 bytes)
///   - Element offset in bytes (4 bytes as UInt32, with 4 bytes padding)
///
/// **Warning:** This code relies on Swift's internal ABI and may break in future Swift versions.
struct TupleType {
    /// Raw pointer to the tuple's metadata structure in memory.
    private let metadata: UnsafeRawPointer

    /// Creates a tuple type inspector for the given type.
    ///
    /// - Parameter type: The tuple type to inspect (e.g., `(Int, String, Bool).self`)
    ///
    /// This initializer converts the type metadata into a raw pointer that can be used
    /// to read the tuple's internal structure. The `unsafeBitCast` reinterprets the
    /// type value (which is itself a pointer to metadata) as a raw memory address.
    init(_ type: Any.Type) {
        self.metadata = unsafeBitCast(type, to: UnsafeRawPointer.self)
    }

    /// The number of elements in the tuple.
    ///
    /// Reads the element count from offset 8 in the metadata structure.
    /// This is the second field in the tuple metadata layout (after the kind field at offset 0).
    var count: Int {
        metadata.advanced(by: MemoryLayout<Int>.size).load(as: Int.self)
    }

    /// Returns the type of the tuple element at the specified index.
    ///
    /// - Parameter index: The zero-based index of the element
    /// - Returns: The type of the element (e.g., `Int.self`, `String.self`)
    ///
    /// **Implementation Details:**
    /// - Element descriptors start at byte offset 24 (after kind, numElements, and labels pointer)
    /// - Each element descriptor is 16 bytes: 8-byte type pointer + 4-byte offset + 4-byte padding
    /// - To access element N: base + 24 + (N * 16) gives us the type pointer
    /// - The type pointer is then cast back to `Any.Type` using `unsafeBitCast`
    func type(at index: Int) -> Any.Type {
        precondition(index >= 0 && index < count, "Index out of bounds")

        // Elements start at offset 24 (after kind, numElements, labels)
        // Each element is (Type: 8 bytes, Offset: 4 bytes, Padding: 4 bytes) = 16 bytes total
        let elementStart: UnsafeRawPointer = metadata.advanced(by: 24)
        let typePointer: Int = elementStart.advanced(by: index * 16).load(as: Int.self)

        return unsafeBitCast(typePointer, to: Any.Type.self)
    }

    /// Returns the byte offset of the tuple element at the specified index.
    ///
    /// - Parameter index: The zero-based index of the element
    /// - Returns: The byte offset from the start of the tuple value in memory
    ///
    /// This tells you where in memory each element is located within a tuple instance.
    /// For example, in `(Int, String, Bool)`, the Bool might be at offset 24 bytes.
    ///
    /// **Implementation Details:**
    /// - The offset is stored 8 bytes after the type pointer in each element descriptor
    /// - Offsets are stored as UInt32 (4 bytes) with 4 bytes of padding after
    /// - To access offset for element N: base + 24 + (N * 16) + 8
    func elementOffset(at index: Int) -> Int {
        precondition(index >= 0 && index < count, "Index out of bounds")

        // Each element descriptor is 16 bytes: Type (8 bytes) + Offset (4 bytes) + Padding (4 bytes)
        let elementStart: UnsafeRawPointer = metadata.advanced(by: 24)
        let offset: UInt32 = elementStart.advanced(by: index * 16 + 8).load(as: UInt32.self)

        return Int(offset)
    }
}

extension TupleType {
    fileprivate var tupleDescriptor: TupleMetadata {
        let desc: TupleMetadata = metadata.load(as: TupleMetadata.self)
        return desc
    }
}

/// Internal representation of tuple metadata structure.
///
/// This struct mirrors the first two fields of Swift's tuple metadata layout.
/// It's used for an alternative (currently unused) approach to reading tuple information
/// through structured access rather than pointer arithmetic.
///
/// - Note: The methods in this struct are not currently used by `TupleType`.
private struct TupleMetadata {
    /// The kind of type metadata (identifies this as a tuple).
    let kind: Int
    /// The number of elements in the tuple.
    let numElements: Int

    /// Alternative implementation: Returns the type at the specified index.
    ///
    /// This method uses structured access through the `TupleMetadata` layout.
    /// It navigates past:
    /// 1. The TupleMetadata header (kind + numElements)
    /// 2. The labels pointer (Int)
    /// 3. Then reads from the array of type pointers
    ///
    /// - Parameter index: The zero-based index of the element
    /// - Returns: The type of the element
    func elementType(at index: Int) -> Any.Type {
        // Start from the address of this struct and navigate past the header
        let baseAddress: UnsafeRawPointer = withUnsafePointer(to: self) { ptr in
            let base: UnsafeRawPointer = .init(ptr)
            return
                base
                .advanced(by: MemoryLayout<TupleMetadata>.size)  // Skip kind + numElements
                .advanced(by: MemoryLayout<Int>.size)  // Skip labels pointer
        }

        // Read the type pointer from the array
        let typeAddress: UnsafeRawPointer = baseAddress.advanced(by: index * MemoryLayout<Int>.size)
        let typePointer: Int = typeAddress.load(as: Int.self)
        let type: Any.Type = unsafeBitCast(typePointer, to: Any.Type.self)
        return type
    }

    /// Alternative implementation: Returns the byte offset at the specified index.
    ///
    /// This navigates to the offset array, which comes after the type pointer array.
    /// Memory layout:
    /// 1. TupleMetadata header (kind + numElements)
    /// 2. Labels pointer (Int)
    /// 3. Array of type pointers (numElements * 8 bytes)
    /// 4. Array of offsets (numElements * 4 bytes)
    ///
    /// - Parameter index: The zero-based index of the element
    /// - Returns: The byte offset from the start of a tuple instance
    func elementOffset(at index: Int) -> Int {
        // Navigate past the header, labels, and all type pointers to reach the offsets array
        let baseAddress: UnsafeRawPointer = withUnsafePointer(to: self) { ptr in
            UnsafeRawPointer(ptr)
                .advanced(by: MemoryLayout<TupleMetadata>.size)  // Skip kind + numElements
                .advanced(by: MemoryLayout<Int>.size)  // Skip labels pointer
                .advanced(by: numElements * MemoryLayout<Int>.size)  // Skip all type pointers
        }

        // Read the offset as UInt32 from the offsets array
        let offsetAddress: UnsafeRawPointer = baseAddress.advanced(
            by: index * MemoryLayout<UInt32>.size)
        let offset: UInt32 = offsetAddress.load(as: UInt32.self)

        return Int(offset)
    }
}

extension String {
    func slice(_ size: Int) -> [String] {
        guard size > 0 else { return [] }

        var result: [String] = []
        var startIndex: String.Index = self.startIndex

        while startIndex < self.endIndex {
            let endIndex: String.Index =
                self.index(startIndex, offsetBy: size, limitedBy: self.endIndex) ?? self.endIndex
            let chunk: String = String(self[startIndex..<endIndex])
            result.append(chunk)
            startIndex = endIndex
        }

        return result
    }
}

struct ViewInputs {
    let position: Attribute<CGPoint>
    let size: Attribute<CGSize>
}

struct ViewOutputs {
    let layoutComputer: Attribute<LayoutComputer>
    let displayList: Attribute<DisplayList>
}

extension ViewOutputs: CustomStringConvertible {
    var description: String {
        "ViewOutputs"
    }
}

struct ViewListOutputs {
    let viewList: Attribute<any ViewList>

    init(viewList: Attribute<any ViewList>) {
        self.viewList = viewList
    }
}

extension ViewListOutputs: CustomStringConvertible {
    var description: String {
        "ViewListOutputs"
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
    static func makeView(_ view: Attribute<Self>, inputs: ViewInputs) -> ViewOutputs
    static func makeViewList(_ view: Attribute<Self>) -> ViewListOutputs
}

protocol ViewList {
    typealias MakeViewOutputs = (ViewInputs) -> ViewOutputs

    func makeViewOutputs(
        inputs: ViewInputs,
        makeViewOutputs:
            @escaping (_ inputs: ViewInputs, _ makeViewOutputs: MakeViewOutputs) -> ViewOutputs?
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
        makeViewOutputs:
            @escaping (_ inputs: ViewInputs, _ makeViewOutputs: MakeViewOutputs) -> ViewOutputs?
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

extension BaseViewList: CustomStringConvertible {
    var description: String {
        "BaseViewList with \(elements.count) elements"
    }
}

struct MergedViewList: ViewList {
    private let viewLists: [Attribute<any ViewList>]

    init(viewLists: [Attribute<any ViewList>]) {
        self.viewLists = viewLists
    }

    func makeViewOutputs(
        inputs: ViewInputs,
        makeViewOutputs: (_ inputs: ViewInputs, _ makeViewOutputs: MakeViewOutputs) -> ViewOutputs?
    ) -> [ViewOutputs] {
        withoutActuallyEscaping(makeViewOutputs) { escapingMakeViewOutputs in
            viewLists.flatMap { viewList in
                viewList.wrappedValue.makeViewOutputs(
                    inputs: inputs,
                    makeViewOutputs: escapingMakeViewOutputs
                )
            }
        }
    }
}

extension MergedViewList: CustomStringConvertible {
    var description: String {
        "MergedViewList with \(viewLists.count) lists"
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
        makeViewOutputs(inputs, makeOutputs)
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

extension DisplayList: CustomStringConvertible {
    var description: String {
        if items.isEmpty {
            return "Empty"
        }

        let parts: [String] = items.map { item in
            switch item {
            case .command(let command):
                return "\(command.text) at \(command.position)"
            case .childList(let list):
                return "childList(\(list.items.count) items)"
            }
        }

        return parts.joined(separator: "\n")
    }
}

// MARK: - Views

struct Text: View {
    private let text: String

    init(_ text: String) {
        self.text = text
    }

    static func makeView(_ view: Attribute<Self>, inputs: ViewInputs) -> ViewOutputs {
        let layoutComputer = Attribute("Text Layout Computer") {
            let text: String = view.wrappedValue.text
            return LayoutComputer { proposedSize in
                let lines: [String] =
                    if let proposedWidth = proposedSize.width {
                        text.slice(Int(proposedWidth))
                    } else {
                        [text]
                    }
                let maxWidth = lines.map { $0.count }.max() ?? 0
                return CGSize(
                    width: CGFloat(maxWidth),
                    height: CGFloat(lines.count)
                )
            } viewGeometries: { rect in
                [rect]
            }
        }

        let displayList = Attribute("Text DisplayList") {
            let textGeometries = layoutComputer.wrappedValue.viewGeometries(
                CGRect(
                    origin: .zero,
                    size: inputs.size.wrappedValue
                )
            )
            let textGeometry = textGeometries[0]

            let text: String = view.wrappedValue.text
            let lines: [String] = text.slice(Int(textGeometry.width))

            let inputPosition: CGPoint = inputs.position.wrappedValue

            return DisplayList(
                lines.enumerated().map { index, line in
                    return .command(
                        PutLineCommand(
                            text: line,
                            position: CGPoint(
                                x: 0,
                                y: inputPosition.y + CGFloat(index)
                            )
                        )
                    )
                }
            )
        }

        return .init(
            layoutComputer: layoutComputer,
            displayList: displayList
        )
    }

    static func makeViewList(_ view: Attribute<Text>) -> ViewListOutputs {
        let element = UnaryViewElement { inputs in
            Self.makeView(view, inputs: inputs)
        }
        let viewList: Attribute<any ViewList> = Attribute("Text ViewList") {
            _ = view.wrappedValue
            return BaseViewList(elements: [element])
        }
        return .init(viewList: viewList)
    }
}

struct TupleView<each V: View>: View {
    private let childViews: (repeat each V)

    init(_ childViews: repeat each V) {
        self.childViews = (repeat each childViews)
    }

    static func makeView(_ view: Attribute<Self>, inputs: ViewInputs) -> ViewOutputs {
        fatalError("Not implemented")
    }

    static func makeViewList(_ view: Attribute<Self>) -> ViewListOutputs {
        let viewTypes: (repeat each V).Type = (repeat each V).self
        let tupleType: TupleType = TupleType(viewTypes)
        var viewListOutputs: [ViewListOutputs] = []

        for index in (0..<tupleType.count) {
            guard let childViewType = tupleType.type(at: index) as? any View.Type else {
                continue
            }

            let childViewOutputs: ViewListOutputs = makeChildViewListOutputs(
                view,
                tupleType: tupleType,
                tupleIndex: index,
                tupleChildViewType: childViewType
            )
            viewListOutputs.append(childViewOutputs)
        }

        let viewLists: [Attribute<any ViewList>] = viewListOutputs.map(\.viewList)
        let viewList: Attribute<any ViewList> = Attribute("TupleView ViewList") {
            _ = view.wrappedValue
            return MergedViewList(viewLists: viewLists)
        }

        return .init(viewList: viewList)
    }

    private static func makeChildViewListOutputs<T: View>(
        _ view: Attribute<Self>,
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
        return T.makeViewList(childView)
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

    static func makeView(_ view: Attribute<Self>, inputs: ViewInputs) -> ViewOutputs {
        let content: Attribute<Content> = view.map(\.content)
        content.label = "\(Content.self)"

        let childViewListOutputs: ViewListOutputs = Content.makeViewList(content)

        var childGeometries: Attribute<[CGRect]>!

        let childViewOutputs = Attribute("VStack Child ViewOutputs") {
            var index: Int = 0
            return childViewListOutputs.viewList.wrappedValue.makeViewOutputs(inputs: inputs) {
                _, makeViewOutputs in
                let currentIndex: Int = index
                let modifiedInputs = ViewInputs(
                    position: Attribute {
                        childGeometries.wrappedValue[currentIndex].origin
                    },
                    size: Attribute {
                        childGeometries.wrappedValue[currentIndex].size
                    }
                )
                index += 1
                return makeViewOutputs(modifiedInputs)
            }
        }

        let layoutComputer = Attribute("VStack LayoutComputer") {
            VStackLayout().layoutComputer(
                for: childViewOutputs.wrappedValue.map(\.layoutComputer.wrappedValue)
            )
        }

        let displayList = Attribute("VStack DisplayList") {
            DisplayList(
                childViewOutputs
                    .wrappedValue
                    .map(\.displayList.wrappedValue)
                    .map { .childList($0) }
            )
        }

        childGeometries = Attribute("VStack Child Geometries") {
            let proposal = ProposedViewSize(inputs.size.wrappedValue)
            let containerSize = layoutComputer.wrappedValue.sizeThatFits(proposal)
            return layoutComputer.wrappedValue.viewGeometries(
                CGRect(
                    origin: .zero,
                    size: containerSize
                )
            )
        }

        return .init(
            layoutComputer: layoutComputer,
            displayList: displayList
        )
    }

    static func makeViewList(_ view: Attribute<Self>) -> ViewListOutputs {
        let offset = MemoryLayout<VStack<Content>>.offset(of: \.content) ?? 0
        let content: Attribute<Content> = view.unsafeOffset(at: offset, as: Content.self)
        return Content.makeViewList(content)
    }
}

// MARK: - ForEach

final class ForEachState<Data: RandomAccessCollection, ID: Hashable, Content: View> {
    private(set) var orderedIds: [ID] = []
    private(set) var itemsById: [ID: Item] = [:]

    func update(with view: Attribute<ForEach<Data, ID, Content>>) {
        orderedIds = []

        let unwrappedView: ForEach<Data, ID, Content> = view.wrappedValue
        var index: Data.Index = unwrappedView.data.startIndex

        while index != unwrappedView.data.endIndex {
            let element: Data.Element = unwrappedView.data[index]
            let id: ID = element[keyPath: unwrappedView.id]

            if let existingItem = itemsById[id] {
                existingItem.index = index
            } else {
                let item: Item = makeCachedItem(
                    for: id,
                    at: index,
                    view: view
                )
                itemsById[id] = item
            }

            orderedIds.append(id)

            unwrappedView.data.formIndex(after: &index)
        }
    }

    private func makeCachedItem(
        for id: ID,
        at index: Data.Index,
        view: Attribute<ForEach<Data, ID, Content>>,
    ) -> Item {
        let childView: Attribute<Content> = makeChildView(for: id, view: view)
        let childViewListOutputs: ViewListOutputs = Content.makeViewList(childView)
        return .init(
            index: index,
            subgraph: .init(),
            viewList: childViewListOutputs.viewList
        )
    }

    private func makeChildView(
        for id: ID,
        view: Attribute<ForEach<Data, ID, Content>>
    ) -> Attribute<Content> {
        Attribute("ForEach Child View \(id)") { [unowned self] in
            guard let elementIndex = self.orderedIds.firstIndex(of: id) else {
                fatalError("Element with ID \(id) not found in orderedIds")
            }
            let view: ForEach<Data, ID, Content> = view.wrappedValue
            let element: Data.Element = view.data[
                view.data.index(view.data.startIndex, offsetBy: elementIndex)]
            return view.makeChildView(element)
        }
    }
}

extension ForEachState {
    final class Item {
        var index: Data.Index
        let subgraph: Subgraph
        let viewList: Attribute<any ViewList>
        var viewOutputs: [ViewOutputs]?

        init(
            index: Data.Index,
            subgraph: Subgraph,
            viewList: Attribute<any ViewList>
        ) {
            self.index = index
            self.subgraph = subgraph
            self.viewList = viewList
        }
    }
}

struct ForEachViewList<Data: RandomAccessCollection, ID: Hashable, Content: View>: ViewList {
    private let view: Attribute<ForEach<Data, ID, Content>>
    private let state: ForEachState<Data, ID, Content>

    init(
        view: Attribute<ForEach<Data, ID, Content>>,
        state: ForEachState<Data, ID, Content>
    ) {
        self.view = view
        self.state = state
    }

    func makeViewOutputs(
        inputs: ViewInputs,
        makeViewOutputs: @escaping (ViewInputs, MakeViewOutputs) -> ViewOutputs?
    ) -> [ViewOutputs] {
        var viewOutputs: [ViewOutputs] = []
        for elementId in state.orderedIds {
            guard let stateItem = state.itemsById[elementId] else { continue }
            if let cachedOutputs = stateItem.viewOutputs {
                viewOutputs.append(contentsOf: cachedOutputs)
            } else {
                let outputs = stateItem.viewList.wrappedValue.makeViewOutputs(
                    inputs: inputs,
                    makeViewOutputs: makeViewOutputs
                )
                stateItem.viewOutputs = outputs
                viewOutputs.append(contentsOf: outputs)
            }
        }
        return viewOutputs
    }
}

extension ForEachViewList: CustomStringConvertible {
    var description: String {
        "ForEachViewList with \(state.orderedIds.count) items"
    }
}

struct ForEach<Data: RandomAccessCollection, ID: Hashable, Content: View>: View {
    let data: Data
    let id: KeyPath<Data.Element, ID>
    let makeChildView: (Data.Element) -> Content

    init(
        _ data: Data,
        id: KeyPath<Data.Element, ID>,
        makeChildView: @escaping (Data.Element) -> Content
    ) {
        self.data = data
        self.id = id
        self.makeChildView = makeChildView
    }

    static func makeView(_ view: Attribute<Self>, inputs: ViewInputs) -> ViewOutputs {
        fatalError("Not implemented")
    }

    static func makeViewList(_ view: Attribute<Self>) -> ViewListOutputs {
        let state = ForEachState<Data, ID, Content>()

        let viewList: Attribute<any ViewList> = Attribute("ForEach ViewList") {
            state.update(with: view)
            return ForEachViewList(view: view, state: state)
        }

        return .init(viewList: viewList)
    }
}

extension ForEach: CustomStringConvertible {
    var description: String {
        "ForEach with \(data.count) elements"
    }
}

@Test
func main() {
    @Attribute("Screen position") var position: CGPoint = .zero
    @Attribute("Screen size") var size = CGSize(width: 2, height: 20)
    let inputs = ViewInputs(
        position: $position,
        size: $size
    )
    @Attribute var view = VStack(
        TupleView(
            Text("He"),
            Text("ll")
        )
    )
    $view.label = "\(type(of: view))"

    let outputs = type(of: view).makeView($view, inputs: inputs)

    _ = outputs.displayList.wrappedValue

    copyToClipboard(Graph.current.description)
}

@Test
func forEach() {
    @Attribute("Screen position") var position: CGPoint = .zero
    @Attribute("Screen size") var size = CGSize(width: 10, height: 20)
    let inputs = ViewInputs(
        position: $position,
        size: $size
    )
    @Attribute("Users") var users: [User] = [
        User(id: 1, name: "Alice")
    ]
    @Attribute var view = VStack(
        ForEach(users, id: \.id) { user in
            Text(user.name)
        }
    )
    $view.label = "\(type(of: view))"

    let outputs = type(of: view).makeView($view, inputs: inputs)

    _ = outputs.displayList.wrappedValue

    users = [
        User(id: 1, name: "Alice"),
        User(id: 2, name: "Bob"),
    ]

    _ = outputs.displayList.wrappedValue

    copyToClipboard(Graph.current.description)
}

private func copyToClipboard(_ string: String) {
    let pasteboard: NSPasteboard = .general
    pasteboard.clearContents()
    pasteboard.setString(string, forType: .string)
}

private struct User: Identifiable {
    let id: Int
    let name: String
}

extension User: CustomStringConvertible {
    var description: String {
        name
    }
}
