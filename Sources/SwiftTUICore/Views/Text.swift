//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 25/11/2025.
//

import AttributeGraph
import Foundation
import Geometry

public struct Text: UnaryView, PrimitiveView {
    private let text: () -> String

    public init(_ text: @autoclosure @escaping () -> String) {
        self.text = text
    }
}

extension Text {
    public static func makeView(_ view: Attribute<Text>, inputs: ViewInputs) -> ViewOutputs {
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
                let dimensions: ViewDimensions = .init(frame: rect)
                return [ViewGeometry(dimensions: dimensions)]
            }
        }

        let textGeometry = Attribute {
            let layoutComputer: LayoutComputer = layoutComputer.wrappedValue
            let inputsPosition: Point = inputs.position.wrappedValue
            let inputsSize: Size = inputs.size.wrappedValue
            let textSize: Size = layoutComputer.sizeThatFits(.init(inputsSize))
            return layoutComputer.childGeometries(
                in: .init(origin: inputsPosition, size: textSize)
            )[0]
        }
        textGeometry.label = "Text Geometry"

        let displayList = Attribute {
            let textGeometry: ViewGeometry = textGeometry.wrappedValue
            let viewOrigin: Point = textGeometry.dimensions.origin
            let viewSize: Size = textGeometry.dimensions.size
            let lines: [String] = split(resolvedText.wrappedValue, by: Int(viewSize.width))
            let items = lines.enumerated().map { index, line in
                DisplayList.Item(
                    content: .command(.putLine(line)),
                    frame: .init(
                        x: viewOrigin.x,
                        y: viewOrigin.y + Double(index),
                        width: viewSize.width,
                        height: 1
                    )
                )
            }
            return DisplayList(items)
        }
        displayList.label = "Text Display List"

        resolvedText.label = "Resolved Text"
        layoutComputer.label = "Text Layout Computer"

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
            let endIndex: String.Index =
                text.index(
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
    public var description: String {
        "Text"
    }
}
