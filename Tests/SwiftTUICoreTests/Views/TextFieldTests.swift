//
//  TextFieldTests.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 21/05/2026.
//

import AttributeGraph
import Foundation
import Geometry
import Terminal
import Testing

@testable import SwiftTUI
@testable import SwiftTUICore

@Suite("TextField")
@MainActor
struct TextFieldTests {
    @Test
    func `Empty unfocused renders placeholder text`() async {
        let textProbe: TextProbe = .init(initial: "")
        await expectView(in: Size(width: 6, height: 1)) {
            TextField("name", text: textProbe.binding)
        } toRender: {
            "name.."
        }
    }

    @Test
    func `Non-empty text renders verbatim`() async {
        let textProbe: TextProbe = .init(initial: "hi")
        await expectView(in: Size(width: 6, height: 1)) {
            TextField("name", text: textProbe.binding)
        } toRender: {
            "hi...."
        }
    }

    @Test
    func `TextField contributes one focusable node`() {
        let textProbe: TextProbe = .init(initial: "")
        let outputs = setup(textProbe: textProbe)
        let nodes = flattenNodes(outputs.focusList?.wrappedValue ?? .empty)
        #expect(nodes.count == 1)
    }

    @Test
    func `computeWindow returns full text when it fits`() {
        let (window, cursor, start) = TextFieldVisual.computeWindow(text: "hi", cursor: 1, width: 5)
        #expect(window == "hi")
        #expect(cursor == 1)
        #expect(start == 0)
    }

    @Test
    func `computeWindow scrolls so cursor stays visible`() {
        // "hello world" 11 chars, width 5, cursor at end (11).
        let (window, cursor, _) = TextFieldVisual.computeWindow(text: "hello world", cursor: 11, width: 5)
        #expect(window.count <= 5)
        #expect(cursor >= 0 && cursor < 5)
        // Cursor at end → window ends with last chars of text.
        #expect("hello world".hasSuffix(window))
    }

    @Test
    func `computeWindow is sticky and only scrolls on cursor edge crossing`() {
        // After scrolling to the end of "hello world" (width 5, cursor 11),
        // moving the cursor back one cell keeps the window stable.
        let initial = TextFieldVisual.computeWindow(
            text: "hello world", cursor: 11, width: 5, previousStart: 0
        )
        #expect(initial.start == 7)

        // Cursor moves left into the visible window — no scroll.
        let stable = TextFieldVisual.computeWindow(
            text: "hello world", cursor: 10, width: 5, previousStart: initial.start
        )
        #expect(stable.start == 7)
        #expect(stable.cursorOffset == 3)

        // Cursor crosses the left edge — window snaps left.
        let leftSnap = TextFieldVisual.computeWindow(
            text: "hello world", cursor: 6, width: 5, previousStart: 7
        )
        #expect(leftSnap.start == 6)
        #expect(leftSnap.cursorOffset == 0)
    }

    @Test
    func `Focus router skips events marked as consumed`() {
        let manager: FocusManager = .init()
        manager.rebuild(from: FocusList(
            .node(FocusableNode(id: FocusNodeID("a"), frame: Rect(x: 0, y: 0, width: 1, height: 1))),
            .node(FocusableNode(id: FocusNodeID("b"), frame: Rect(x: 0, y: 2, width: 1, height: 1)))
        ))
        manager.setFocus(FocusNodeID("a"))

        let router: FocusKeyboardRouter = .init(manager: manager)
        let event: Keyboard.Event = .keyDown(.arrowDown)
        event.consume()
        router.handle(event)

        // Router should have skipped — focus stays on "a".
        #expect(manager.currentFocus == FocusNodeID("a"))
    }

    @Test
    func `Focus router moves when event is not consumed`() {
        let manager: FocusManager = .init()
        manager.rebuild(from: FocusList(
            .node(FocusableNode(id: FocusNodeID("a"), frame: Rect(x: 0, y: 0, width: 1, height: 1))),
            .node(FocusableNode(id: FocusNodeID("b"), frame: Rect(x: 0, y: 2, width: 1, height: 1)))
        ))
        manager.setFocus(FocusNodeID("a"))

        let router: FocusKeyboardRouter = .init(manager: manager)
        router.handle(.keyDown(.arrowDown))

        #expect(manager.currentFocus == FocusNodeID("b"))
    }

    // MARK: - helpers

    private func setup(textProbe: TextProbe) -> ViewOutputs {
        @Attribute var screenOrigin: Point = .zero
        @Attribute var screenSize: Size = .init(width: 10, height: 1)
        @Attribute var viewPhase: ViewPhase = .active
        @Attribute var environment: EnvironmentValues = .init()
        @Attribute var view = TextField("p", text: textProbe.binding)

        let inputs = ViewInputs(
            position: $screenOrigin,
            size: $screenSize,
            phase: $viewPhase,
            environment: $environment,
            storage: .init()
        )
        let outputs = type(of: view).makeView($view, inputs: inputs)
        _ = outputs.displayList.wrappedValue
        return outputs
    }

    private func flattenNodes(_ list: FocusList) -> [FocusableNode] {
        var result: [FocusableNode] = []
        for item in list.items {
            switch item {
            case .node(let n): result.append(n)
            case .list(let s): result.append(contentsOf: flattenNodes(s))
            case .group(let g): result.append(contentsOf: flattenNodes(g.children))
            }
        }
        return result
    }
}

@MainActor
private final class TextProbe {
    private let attribute: Attribute<String>

    init(initial: String) {
        self.attribute = Attribute(wrappedValue: initial)
    }

    var value: String { attribute.wrappedValue }

    var binding: Binding<String> {
        Binding(
            get: { self.attribute.wrappedValue },
            set: { self.attribute.wrappedValue = $0 }
        )
    }
}
