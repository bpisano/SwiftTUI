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
    @Binding private var text: String
    private let placeholder: String

    @State private var cursor: Int = 0
    @State private var isFocused: Bool = false
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
            isEnabled: isEnabled
        )
        .focused($isFocused)
        .onKeyDown { event in
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
        // Skip whitespace at cursor.
        while pos < count {
            let idx = text.index(text.startIndex, offsetBy: pos)
            guard text[idx].isWhitespace else { break }
            pos += 1
        }
        // Walk forward over the word.
        while pos < count {
            let idx = text.index(text.startIndex, offsetBy: pos)
            guard !text[idx].isWhitespace else { break }
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

struct TextFieldVisual: View, PrimitiveView {
    let text: String
    let cursor: Int
    let placeholder: String
    let isFocused: Bool
    let isEnabled: Bool
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
                    commands.append(.init(.backgroundColor(.softWhite), in: cursorFrame))
                }
                return DisplayList(commands: commands)
            }

            let (window, cursorOffset) = computeWindow(
                text: value.text,
                cursor: value.cursor,
                width: availableWidth
            )
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
                commands.append(.init(.backgroundColor(.softWhite), in: cursorFrame))
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

    private static func naturalWidth(value: TextFieldVisual) -> Int {
        // +1 reserves a cell for cursor placed past the last character.
        max(1, max(value.text.count + 1, value.placeholder.count))
    }

    /// Picks the visible substring around `cursor` so the cursor cell stays in
    /// view when text is longer than `width`. Returns the windowed string plus
    /// the cursor's offset inside the window.
    static func computeWindow(
        text: String,
        cursor: Int,
        width: Int
    ) -> (window: String, cursorOffset: Int) {
        guard width > 0 else { return ("", 0) }
        let clampedCursor: Int = max(0, min(cursor, text.count))

        // Text + virtual end-cursor cell fits inside the available width.
        if text.count + 1 <= width {
            return (text, clampedCursor)
        }

        // Scroll: keep cursor in view, biased so cursor sits near the middle.
        let half: Int = width / 2
        var start: Int = max(0, clampedCursor - half)
        var end: Int = min(text.count, start + width)
        start = max(0, end - width)
        end = min(text.count, start + width)

        let startIdx = text.index(text.startIndex, offsetBy: start)
        let endIdx = text.index(text.startIndex, offsetBy: end)
        let window = String(text[startIdx..<endIdx])
        let cursorOffset: Int = min(width - 1, max(0, clampedCursor - start))
        return (window, cursorOffset)
    }
}
