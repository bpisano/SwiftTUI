//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 18/11/2025.
//

import AttributeGraph
import CoreGraphics
import Playgrounds

struct ViewInputs {
    let frame: Attribute<CGRect>
}

extension ViewInputs: CustomStringConvertible {
    var description: String {
        "ViewInputs<br />frame: \(frame.wrappedValue)"
    }
}

struct ViewOutputs {
    let layoutComputer: Attribute<LayoutComputer>
    let displayList: Attribute<DisplayList>
}

protocol View {
    static func makeView(attribute: Attribute<Self>, inputs: ViewInputs) -> ViewOutputs
}

struct Color: View {
    let name: String
}

extension Color {
    static func makeView(attribute: Attribute<Color>, inputs: ViewInputs) -> ViewOutputs {
        @Attribute var layoutComputer = LayoutComputer { proposedSize in
            proposedSize.replacingUnspecifiedDimensions()
        }

        @Attribute var displayList = DisplayList(
            commands: [
                .init(
                    name: attribute.wrappedValue.name,
                    frame: inputs.frame.wrappedValue
                )
            ]
        )

        $layoutComputer.label = "Color Layout Computer"
        $displayList.label = "Color Display List"

        return ViewOutputs(
            layoutComputer: $layoutComputer,
            displayList: $displayList
        )
    }
}

struct DisplayList {
    let commands: [Command]

    struct Command {
        let name: String
        let frame: CGRect
    }
}

extension DisplayList: CustomStringConvertible {
    var description: String {
        var result = ""
        for command in commands {
            result += "(\(command.name), frame: \(command.frame))"
        }
        return result
    }
}

struct ProposedViewSize {
    static let zero: ProposedViewSize = .init(width: nil, height: nil)
    static let infinity: ProposedViewSize = .init(width: .infinity, height: .infinity)
    static let unspecified: ProposedViewSize = .init(width: nil, height: nil)

    let width: Double?
    let height: Double?

    init(width: Double?, height: Double?) {
        self.width = width
        self.height = height
    }

    init(_ size: CGSize) {
        self.width = size.width.isFinite ? size.width : nil
        self.height = size.height.isFinite ? size.height : nil
    }

    func replacingUnspecifiedDimensions(
        by size: CGSize = .init(width: 10, height: 10)
    ) -> CGSize {
        CGSize(
            width: width ?? size.width,
            height: height ?? size.height
        )
    }
}

struct ViewLayoutRule<T>: Rule {
    private let rule: () -> T

    init(rule: @escaping () -> T) {
        self.rule = rule
    }

    func evaluate() -> T {
        rule()
    }
}

struct LayoutComputer {
    let sizeThatFits: (ProposedViewSize) -> CGSize
}

typealias LayoutProxy = LayoutComputer

protocol Layout {
    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: [LayoutProxy]
    ) -> CGSize

    func place(
        in bounds: CGRect,
        subviews: [LayoutProxy]
    )
}

extension Layout {
    func layoutComputer(for subviews: [LayoutProxy]) -> LayoutComputer {
        LayoutComputer { proposedSize in
            sizeThatFits(proposal: proposedSize, subviews: subviews)
        }
    }
}

struct HStackLayout: Layout {
    func sizeThatFits(proposal: ProposedViewSize, subviews: [LayoutProxy]) -> CGSize {
        .zero
    }

    func place(in bounds: CGRect, subviews: [LayoutProxy]) {

    }

    private func frames(proposedSize: ProposedViewSize, subviews: [LayoutProxy]) -> [CGRect] {
        var frames: [CGRect] = []

        var xOffset: Double = 0
        for subview in subviews {
            let size = subview.sizeThatFits(proposedSize)
            let frame = CGRect(
                x: xOffset,
                y: 0,
                width: size.width,
                height: size.height
            )
            frames.append(frame)
            xOffset += size.width
        }

        return frames
    }
}

struct LayoutRule: Rule {
    private let sizeThatFits: (ProposedViewSize) -> CGSize

    init(sizeThatFits: @escaping (ProposedViewSize) -> CGSize) {
        self.sizeThatFits = sizeThatFits
    }

    func evaluate() -> LayoutComputer {
        LayoutComputer(sizeThatFits: sizeThatFits)
    }
}

#Playground("Layout") {
    /*
     struct Nested: View {
        @State var toggleState: Bool
    
        var body: {
            Color.blue
                .frame(width: toggleState ? 50 : 100)
        }
     }
    
     struct ContentView: View {
        var body: {
            HStack {
                Color.red
                Nested(toggleState: $toggleState)
            }
        }
     }
     */

    let graph = Graph()
    graph.makeCurrent()

    @Attribute var toggleState = false
    @Attribute var screenSize = CGSize(width: 200, height: 100)

    let redLayoutComputer = Attribute(
        rule: ViewLayoutRule {
            return LayoutComputer { proposedSize in
                proposedSize.replacingUnspecifiedDimensions()
            }
        }
    )

    let nestedLayoutComputer = Attribute(
        rule: ViewLayoutRule {
            let width = toggleState ? 50.0 : 100.0
            return LayoutComputer { proposedSize in
                return CGSize(width: width, height: proposedSize.height ?? 0)
            }
        }
    )

    let hstackLayoutComputer = Attribute(
        rule: ViewLayoutRule {
            let nestedLayoutComputer = nestedLayoutComputer.wrappedValue
            let redLayoutComputer = redLayoutComputer.wrappedValue

            return LayoutComputer { proposedSize in
                // Propose ideal size to first children
                var remainderWidth = proposedSize.width ?? 0
                let childProposal1 = CGSize(
                    width: remainderWidth / 2,
                    height: proposedSize.height ?? 0
                )

                // Update remainder after first child
                let nestedSize = nestedLayoutComputer.sizeThatFits(ProposedViewSize(childProposal1))
                remainderWidth -= nestedSize.width

                // Propose ideal size to second child
                let child2Proposal = CGSize(
                    width: remainderWidth,
                    height: proposedSize.height ?? 0
                )
                let redSize = redLayoutComputer.sizeThatFits(ProposedViewSize(child2Proposal))

                return CGSize(
                    width: redSize.width + nestedSize.width,
                    height: max(redSize.height, nestedSize.height)
                )
            }
        }
    )

    @Attribute var hstackSize = hstackLayoutComputer.wrappedValue
        .sizeThatFits(ProposedViewSize(screenSize))

    $toggleState.label = "Toggle State"
    $screenSize.label = "Screen Size"
    redLayoutComputer.label = "Red Layout Computer"
    nestedLayoutComputer.label = "Nested Layout Computer"
    hstackLayoutComputer.label = "HStack Layout Computer"
    $hstackSize.label = "HStack Size"

    let _ = hstackSize

    print(graph)  // Initial state

    toggleState.toggle()

    print(graph)  // After toggle, before access

    let _ = hstackSize

    print(graph)  // After toggle
}

func run<Content: View>(_ view: Content, inputSize: Attribute<CGSize>) -> ViewOutputs {
    @Attribute var rootAttribute = view
    @Attribute var rootFrame = CGRect(origin: .zero, size: inputSize.wrappedValue)

    let rootInputs = ViewInputs(frame: $rootFrame)
    return Content.makeView(attribute: $rootAttribute, inputs: rootInputs)
}

#Playground("View") {
    let graph = Graph()
    graph.makeCurrent()

    @Attribute var screenSize = CGSize(width: 200, height: 200)
    @Attribute var rootFrame = CGRect(origin: .zero, size: screenSize)
    @Attribute var colorNode = Color(name: "blue")

    $screenSize.label = "screenSize"
    $rootFrame.label = "root frame"
    $colorNode.label = "color node"

    let outputs = run(colorNode, inputSize: $screenSize)
    let displayList = outputs.displayList
    let layoutComputer = outputs.layoutComputer

    layoutComputer.label = "layout computer"
    displayList.label = "display list"

    let _ = displayList.wrappedValue

    print(graph)  // After accessing display list
}
