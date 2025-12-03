//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 25/11/2025.
//

import AttributeGraph
import Foundation
import Geometry

//struct TupleView<each V: View>: MultiView {
//    private let children: (repeat each V)
//
//    init(_ content: (repeat each V)) {
//        self.children = content
//    }
//}
//
//extension TupleView: CustomStringConvertible {
//    var description: String {
//        "TupleView"
//    }
//}
//
//extension TupleView {
//    static func makeView(_ view: Attribute<TupleView<repeat each V>>, inputs: ViewInputs) -> ViewOutputs {
//        let outputsList = makeViewList(view, inputs: inputs)
//        return ViewOutputs(
//            layoutComputer: outputsList.layoutComputers[0],
//            displayList: outputsList.displayList
//        )
//    }
//
//    static func makeViewList(_ view: Attribute<TupleView<repeat each V>>, inputs: ViewInputs) -> ViewListOutputs {
//        var layoutComputers: [Attribute<LayoutComputer>] = []
//
//        func process<Child: View>(_ child: Child) {
//            let attr = Attribute(wrappedValue: child)
//            attr.label = "Test"
//            let outputs = type(of: child).makeView(attr, inputs: inputs)
//            layoutComputers.append(outputs.layoutComputer)
//        }
//
//        func process<Child: UnaryView>(_ child: Child) {
//            let attr = Attribute(wrappedValue: child)
//            attr.label = "Test"
//            let outputs = type(of: child).makeView(attr, inputs: inputs)
//            layoutComputers.append(outputs.layoutComputer)
//        }
//
//        func process<Child: MultiView>(_ child: Child) {
//            let attr = Attribute(wrappedValue: child)
//            attr.label = "Test"
//            let outputs = type(of: child).makeViewList(attr, inputs: inputs)
//            layoutComputers.append(contentsOf: outputs.layoutComputers)
//        }
//
//        for child in repeat each view.wrappedValue.children {
//            process(child)
//        }
//
//        @Attribute var displayList = DisplayList(commands: [])
//
//        return ViewListOutputs(
//            layoutComputers: layoutComputers,
//            displayList: $displayList
//        )
//    }
//
//    static func viewListCount(_ view: Attribute<TupleView<repeat each V>>) -> Int? {
//        var count: Int = 0
//        for child in repeat each view.wrappedValue.children {
//            if let childCount = type(of: child).viewListCount(Attribute(wrappedValue: child)) {
//                count += childCount
//            } else {
//                return nil
//            }
//        }
//        return count
//    }
//}
//
struct HStack<Content: View>: UnaryView {
    @Attribute private var content: Content

    init(_ content: Content) {
        self._content = Attribute(wrappedValue: content)
        $content.label = "HStack Content"
    }
}

extension HStack {
    static func makeView(_ view: Attribute<HStack>, inputs: ViewInputs) -> ViewOutputs {
        let contentOutputs = Content.makeView(view.wrappedValue.$content, inputs: inputs)

        let childGeometries = contentOutputs.layoutComputer.wrappedValue.childGeometries(
            in: inputs.proposalFrame.wrappedValue
        )

        let layoutComputer = Attribute {
            let layout = HStackLayout()
            let layoutComputer = contentOutputs.layoutComputer.wrappedValue
            let hstackLayoutComputer = layout.layoutComputer(for: [layoutComputer])
            return hstackLayoutComputer
        }

        layoutComputer.label = "HStack Layout Computer"

        return ViewOutputs(
            layoutComputer: layoutComputer,
            displayList: contentOutputs.displayList
        )

        //        @Attribute var viewGeometry = ViewGeometry(origin: .zero, size: .zero)
        //
        //        let outputs: ViewOutputs = type(of: children).makeView($children, inputs: inputs)
        //
        //        @Attribute var layoutComputer = LayoutComputer { proposedSize in
        //            let lc = outputs.layoutComputer.wrappedValue
        //            _ = lc.sizeThatFits(proposedSize)
        //            return .zero
        //        } place: { rect, proposal in
        //            let lc = outputs.layoutComputer.wrappedValue
        //            lc.place(in: rect, proposal: proposal)
        //        }
        //
        //        @Attribute var displayList = DisplayList(commands: [])
        //
        //        $layoutComputer.label = "HStack Layout Computer"
        //        $displayList.label = "HStack Display List"
        //
        //        return ViewOutputs(
        //            layoutComputer: $layoutComputer,
        //            displayList: $displayList
        //        )
    }
}
