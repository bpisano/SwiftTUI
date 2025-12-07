//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 20/11/2025.
//

import AttributeGraph
import Foundation
import Geometry
//import Playgrounds

struct ViewOutputsRule<V: View>: Rule {
    let view: Attribute<V>
    let inputs: ViewInputs

    init(
        view: Attribute<V>,
        inputs: ViewInputs
    ) {
        self.view = view
        self.inputs = inputs
    }

    func evaluate() -> ViewOutputs {
        V.makeView(view, inputs: inputs)
    }
}

//#Playground {
//    let graph = Graph()
//    graph.makeCurrent()
//
//    @Attribute var screenSize = Size(width: 20, height: 20)
//    @Attribute var screenRect = Rect(origin: .zero, size: screenSize)
//    let inputs = ViewInputs(frame: $screenRect)
//
//    @Attribute var count: Int = 0
////    @Attribute var view = TupleView(
////        Text("Hello \(count)"),
////        Text("Test")
////    )
//    @Attribute var view = Text("Hello world")
//        .frame(width: 6, alignment: .leading)
//        .frame(width: 3, alignment: .leading)
//    let outputs = type(of: view).makeView($view, inputs: inputs)
//
//    $screenSize.label = "Screen Size"
//    $screenRect.label = "Screen Rect"
//    $count.label = "@State count"
//    $view.label = "\(type(of: view))"
//
//    let _ = outputs.displayList.wrappedValue
//
//    print(graph) // Initial state
//
////    count = 1
////
////    print(graph) // After state change
////
////    let _ = outputs.displayList.wrappedValue
////
////    print(graph) // After re-evaluation
//}
