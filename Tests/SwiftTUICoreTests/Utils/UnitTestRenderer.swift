//
//  UnitTestRenderer.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 16/03/2026.
//

import Foundation
import Testing
import AttributeGraph
import Geometry
@testable import SwiftTUI
@testable import SwiftTUICore

final class UnitTestRenderer<V: View> {
    private var buffer: TerminalBuffer
    private var outputs: ViewOutputs?
    
    var emptyChar: Character = " "
    
    @Attribute private var position: Point = .zero
    @Attribute private var size: Size
    @Attribute private var viewPhase: ViewPhase = .active
    @Attribute private var view: V
    
    init(
        in size: Size,
        @ViewBuilder _ view: () -> V
    ) {
        let viewInstance = view()
        self.buffer = .init(size: size)
        self._size = .init(wrappedValue: size)
        self._view = .init(wrappedValue: viewInstance)
        setup()
    }
    
    private func setup() {
        let inputs: ViewInputs = .init(
            position: $position,
            size: $size,
            phase: $viewPhase,
            storage: .init()
        )
        outputs = V.makeView($view, inputs: inputs)
    }
    
    func render() -> String {
        guard let outputs else {
            assertionFailure("Outputs not set up.")
            return ""
        }
        
        buffer = TerminalBuffer(size: size)
        
        fillBuffer(with: outputs.displayList.wrappedValue)
        
        return buffer.makeStringFrame(emptyChar: emptyChar)
    }
    
    private func fillBuffer(with displayList: DisplayList) {
        for item in displayList.items {
            switch item {
            case let .childList(wrappedDisplayList):
                fillBuffer(with: wrappedDisplayList)
            case let .command(command):
                fillBufferCell(with: command)
            }
        }
    }
    
    private func fillBufferCell(with command: DisplayList.Command) {
        switch command.action {
        case let .putLine(line):
            buffer.putLine(line, at: command.frame.origin)
        }
    }
}

func expectView<V: View>(
    in size: Size,
    @ViewBuilder _ makeView: () -> V,
    toRender expectation: () -> String
) {
    let renderer = UnitTestRenderer(in: size) {
        makeView()
    }
    renderer.emptyChar = "."

    let output: String = renderer.render()
    #expect(output == expectation())
}
