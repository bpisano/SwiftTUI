//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 25/11/2025.
//

import Foundation
import AttributeGraph
import Geometry

struct Text: UnaryView {
    private let text: () -> String

    init(_ text: @autoclosure @escaping () -> String) {
        self.text = text
    }
}

extension Text {
    static func makeView(_ view: Attribute<Text>, inputs: ViewInputs) -> ViewOutputs {
        let resolvedText = Attribute {
            view.wrappedValue.text()
        }

        let layoutComputer = Attribute {
            let resolvedText = resolvedText.wrappedValue
            let textLength = resolvedText.count
            return LayoutComputer { proposal in
                if let proposedWidth = proposal.width {
                    if Double(textLength) <= proposedWidth {
                        return Size(width: Double(textLength), height: 1)
                    } else {
                        var width: Double = 0
                        var height: Double = 1
                        
                        for character in resolvedText {
                            if character == "\n" {
                                height += 1
                                width = 0
                            } else {
                                width += 1
                            }
                            
                            if width >= proposedWidth {
                                width = 0
                                height += 1
                            }
                        }

                        return Size(width: proposedWidth, height: height)
                    }
                } else {
                    return Size(width: Double(textLength), height: 1)
                }
            } childGeometries: { rect in
                [ViewGeometry(frame: rect)]
            }
        }

        let textGeometry = Attribute {
            layoutComputer.wrappedValue.childGeometries(in: inputs.frame.wrappedValue)[0]
        }

        let displayList = Attribute {
            let viewSize: Size = textGeometry.wrappedValue.frame.size
            let lines: [String] = split(resolvedText.wrappedValue, by: Int(viewSize.width))
            let items = lines.enumerated().map { index, line in
                DisplayList.Item(
                    content: .command(.putLine(line)),
                    frame: .init(x: 0, y: Double(index), width: viewSize.width, height: 1)
                )
            }
            return DisplayList(items)
        }

        resolvedText.label = "Resolved Text"
        layoutComputer.label = "Text Layout Computer"
        textGeometry.label = "Text Geometry"
        displayList.label = "Text Display List"

        return ViewOutputs(
            layoutComputer: layoutComputer,
            displayList: displayList
        )
    }

    private static func split(_ text: String, by count: Int) -> [String] {
        guard count > 0 else { return [] }

        var result: [String] = .init()
        var currentIndex: String.Index = text.startIndex

        while currentIndex < text.endIndex {
            let endIndex: String.Index = text.index(
                currentIndex,
                offsetBy: count,
                limitedBy: text.endIndex
            ) ?? text.endIndex

            let chunk: String = .init(text[currentIndex..<endIndex])
            result.append(chunk)

            currentIndex = endIndex
        }

        return result
    }
}

extension Text: CustomStringConvertible {
    var description: String {
        "Text"
    }
}
