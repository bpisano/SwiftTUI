//
//  TextField.swift
//  SwiftTUICore
//
//  Created by Benjamin Pisano on 21/05/2026.
//

import Foundation
import Geometry
import AttributeGraph
import Terminal

public struct TextField: View {
    private let placeholder: String

    @State private var cursor: Int = 0
    @State private var isFocused: Bool = false
    @State private var scrollState: TextFieldScrollState = .init()

    @Binding private var text: String

    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.submitAction) private var submitAction

    public init(
        _ placeholder: String,
        text: Binding<String>
    ) {
        self.placeholder = placeholder
        self._text = text
    }

    public var body: some View {
        TextFieldVisual(
            text: text,
            cursor: clampedCursor,
            placeholder: placeholder,
            isFocused: isFocused,
            isEnabled: isEnabled,
            scrollState: scrollState
        )
        .focused($isFocused)
        .onKeyPressed { event in
            handleKey(event)
        }
    }

    private var clampedCursor: Int {
        max(0, min(cursor, text.count))
    }

    private func handleKey(_ event: Keyboard.Event) {
        guard isFocused, isEnabled else { return }

        switch event.key {
        case .character(let s):
            guard !event.modifiers.contains(.control) else { return }
            guard !event.modifiers.contains(.command) else { return }
            guard Self.isInsertable(s) else { return }
            let value: String
            if event.modifiers.contains(.shift) {
                value = s.uppercased()
            } else {
                value = s
            }
            insert(value)
            event.consume()
        case .space:
            insert(" ")
            event.consume()
        case .delete:
            if event.modifiers.contains(.command) {
                deleteToLineStart()
            } else if event.modifiers.contains(.option) {
                deleteWordBefore()
            } else {
                backspace()
            }
            event.consume()
        case .arrowLeft:
            if event.modifiers.contains(.command) {
                cursor = 0
            } else if event.modifiers.contains(.option) {
                cursor = wordBoundaryBefore(clampedCursor)
            } else if clampedCursor > 0 {
                cursor = clampedCursor - 1
            }
            event.consume()
        case .arrowRight:
            if event.modifiers.contains(.command) {
                cursor = text.count
            } else if event.modifiers.contains(.option) {
                cursor = wordBoundaryAfter(clampedCursor)
            } else if clampedCursor < text.count {
                cursor = clampedCursor + 1
            }
            event.consume()
        case .home:
            cursor = 0
            event.consume()
        case .end:
            cursor = text.count
            event.consume()
        case .enter:
            submitAction?()
            event.consume()
        default:
            break
        }
    }

    private func insert(_ s: String) {
        let idx = text.index(text.startIndex, offsetBy: clampedCursor)
        text.insert(contentsOf: s, at: idx)
        cursor = clampedCursor + s.count
    }

    private func backspace() {
        let position = clampedCursor
        guard position > 0 else { return }
        let removeIdx = text.index(text.startIndex, offsetBy: position - 1)
        text.remove(at: removeIdx)
        cursor = position - 1
    }

    private func deleteWordBefore() {
        let end = clampedCursor
        guard end > 0 else { return }

        // Skip trailing whitespace before cursor.
        var pos = end
        while pos > 0 {
            let idx = text.index(text.startIndex, offsetBy: pos - 1)
            guard text[idx].isWhitespace else { break }
            pos -= 1
        }
        // Walk back over the word.
        while pos > 0 {
            let idx = text.index(text.startIndex, offsetBy: pos - 1)
            guard !text[idx].isWhitespace else { break }
            pos -= 1
        }

        let startIdx = text.index(text.startIndex, offsetBy: pos)
        let endIdx = text.index(text.startIndex, offsetBy: end)
        text.removeSubrange(startIdx..<endIdx)
        cursor = pos
    }

    private func deleteToLineStart() {
        let end = clampedCursor
        guard end > 0 else { return }
        let endIdx = text.index(text.startIndex, offsetBy: end)
        text.removeSubrange(text.startIndex..<endIdx)
        cursor = 0
    }

    private func wordBoundaryBefore(_ from: Int) -> Int {
        var pos = from
        // Skip trailing whitespace.
        while pos > 0 {
            let idx = text.index(text.startIndex, offsetBy: pos - 1)
            guard text[idx].isWhitespace else { break }
            pos -= 1
        }
        // Walk back over the word.
        while pos > 0 {
            let idx = text.index(text.startIndex, offsetBy: pos - 1)
            guard !text[idx].isWhitespace else { break }
            pos -= 1
        }
        return pos
    }

    private func wordBoundaryAfter(_ from: Int) -> Int {
        var pos = from
        let count = text.count
        // Walk forward over any word the cursor is inside (or starts on).
        while pos < count {
            let idx = text.index(text.startIndex, offsetBy: pos)
            guard !text[idx].isWhitespace else { break }
            pos += 1
        }
        // Then skip the gap so the cursor always lands at the start of the
        // *next* word, matching native text editors and SwiftUI semantics.
        while pos < count {
            let idx = text.index(text.startIndex, offsetBy: pos)
            guard text[idx].isWhitespace else { break }
            pos += 1
        }
        return pos
    }

    /// Drops characters that aren't meant to be inserted as text — typically
    /// modifier-key keypresses reported by kitty's progressive keyboard mode
    /// as private-use Unicode scalars (U+E000…U+F8FF).
    private static func isInsertable(_ s: String) -> Bool {
        for scalar in s.unicodeScalars {
            if scalar.value < 0x20 || scalar.value == 0x7F {
                return false
            }
            if scalar.value >= 0xE000 && scalar.value <= 0xF8FF {
                return false
            }
        }
        return !s.isEmpty
    }
}

/// Holds the horizontal scroll offset for a `TextField` across renders so
/// the visible window only shifts when the caret leaves it. Mutated by the
/// `TextFieldVisual` primitive on the main actor during layout; not observed
/// by the attribute graph (changes don't trigger a redraw on their own).
final class TextFieldScrollState: @unchecked Sendable {
    var start: Int = 0
}

struct TextFieldVisual: View, PrimitiveView {
    let text: String
    let cursor: Int
    let placeholder: String
    let isFocused: Bool
    let isEnabled: Bool
    let scrollState: TextFieldScrollState
}

extension TextFieldVisual {
    static func makeView(
        _ view: Attribute<TextFieldVisual>,
        inputs: ViewInputs
    ) -> ViewOutputs {
        let layoutComputer = Attribute("TextFieldVisual LayoutComputer") {
            let value = view.wrappedValue
            let natural: Int = naturalWidth(value: value)
            return LayoutComputer { proposedSize in
                let width: Double
                if let proposed = proposedSize.width, proposed.isFinite {
                    width = max(1, proposed)
                } else {
                    width = max(1, Double(natural))
                }
                return Size(width: width, height: 1)
            } viewGeometries: { rect in
                [rect]
            }
        }

        let displayList = Attribute("TextFieldVisual DisplayList") {
            let value = view.wrappedValue
            let frame = inputs.frame
            let availableWidth = max(0, Int(frame.width))
            guard availableWidth > 0 else { return DisplayList([]) }

            var commands: [DisplayList.Command] = []

            if value.text.isEmpty {
                let displayed = String(value.placeholder.prefix(availableWidth))
                if !displayed.isEmpty {
                    let textFrame = Rect(
                        origin: frame.origin,
                        size: Size(width: Double(displayed.count), height: 1)
                    )
                    commands.append(.init(.putLine(displayed), in: textFrame))
                    commands.append(.init(.foregroundColor(.gray), in: textFrame))
                }
                if value.isFocused, value.isEnabled {
                    let cursorFrame = Rect(
                        origin: frame.origin,
                        size: Size(width: 1, height: 1)
                    )
                    appendFakeCursor(into: &commands, at: cursorFrame)
                }
                return DisplayList(commands: commands)
            }

            let result = computeWindow(
                text: value.text,
                cursor: value.cursor,
                width: availableWidth,
                previousStart: value.scrollState.start
            )
            value.scrollState.start = result.start
            let window = result.window
            let cursorOffset = result.cursorOffset
            if !window.isEmpty {
                let textFrame = Rect(
                    origin: frame.origin,
                    size: Size(width: Double(window.count), height: 1)
                )
                commands.append(.init(.putLine(window), in: textFrame))
            }

            if value.isFocused, value.isEnabled {
                let cursorX = frame.origin.x + Double(cursorOffset)
                let cursorFrame = Rect(
                    origin: Point(x: cursorX, y: frame.origin.y),
                    size: Size(width: 1, height: 1)
                )
                appendFakeCursor(into: &commands, at: cursorFrame)
            }

            return DisplayList(commands: commands)
        }

        return .init(
            layoutComputer: layoutComputer,
            displayList: displayList
        )
    }

    static func makeViewList(
        _ view: Attribute<TextFieldVisual>,
        inputs: ViewListInputs
    ) -> ViewListOutputs {
        .unaryViewListOutputs("TextFieldVisual ViewList", implicitId: inputs.implicitId) { inputs in
            Self.makeView(view, inputs: inputs)
        }
    }

    /// Draws the fake cursor: a `.cursorAnchor` (so the terminal anchors IME
    /// composition glyphs at the right spot even though the real cursor is
    /// hidden) plus an inverted-color cell (`bg=softWhite`, `fg=black`) that
    /// simulates a blinking block caret without flickering as bytes flow
    /// during render.
    private static func appendFakeCursor(
        into commands: inout [DisplayList.Command],
        at frame: Rect
    ) {
        commands.append(.init(.cursorAnchor, in: frame))
        commands.append(.init(.backgroundColor(.white), in: frame))
        commands.append(.init(.foregroundColor(.black), in: frame))
    }

    private static func naturalWidth(value: TextFieldVisual) -> Int {
        // +1 reserves a cell for cursor placed past the last character.
        max(1, max(value.text.count + 1, value.placeholder.count))
    }

    /// Picks the visible substring around `cursor` so the caret stays in
    /// view when text is longer than `width`. Sticky scroll: the window only
    /// shifts when the cursor leaves the previously visible range
    /// (`previousStart ..< previousStart + width`). When typing past the
    /// last character of a full field, reserves the rightmost cell for the
    /// caret so it doesn't overlay the last letter.
    static func computeWindow(
        text: String,
        cursor: Int,
        width: Int,
        previousStart: Int = 0
    ) -> (window: String, cursorOffset: Int, start: Int) {
        guard width > 0 else { return ("", 0, 0) }
        let clampedCursor: Int = max(0, min(cursor, text.count))

        // Text + virtual end-cursor cell fits inside the available width:
        // no scrolling needed, anchor at 0.
        if text.count + 1 <= width {
            return (text, clampedCursor, 0)
        }

        // Reserve the rightmost cell for the caret when it sits past the
        // last character, so the cursor block doesn't overlay a letter.
        let maxStart = max(0, text.count - (width - 1))
        var start = max(0, min(previousStart, maxStart))
        if clampedCursor < start {
            start = clampedCursor
        }
        let rightEdge = start + width - 1
        if clampedCursor > rightEdge {
            start = clampedCursor - (width - 1)
        }
        start = max(0, min(start, maxStart))

        let end = min(text.count, start + width)
        let startIdx = text.index(text.startIndex, offsetBy: start)
        let endIdx = text.index(text.startIndex, offsetBy: end)
        let window = String(text[startIdx..<endIdx])
        let cursorOffset: Int = clampedCursor - start
        return (window, cursorOffset, start)
    }
}
