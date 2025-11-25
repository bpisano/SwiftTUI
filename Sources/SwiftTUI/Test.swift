//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 20/11/2025.
//

import AttributeGraph
import Foundation
import Geometry
import Playgrounds

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

#Playground {
    let graph = Graph()
    graph.makeCurrent()

    @Attribute var screenSize = Size(width: 2, height: 200)
    @Attribute var screenRect = Rect(origin: .zero, size: screenSize)
    let inputs = ViewInputs(frame: $screenRect)

    @Attribute var view = Text("Hello")
    var outputs = type(of: view).makeView($view, inputs: inputs)

    $screenSize.label = "Screen Size"
    $screenRect.label = "Screen Rect"
    $view.label = "Text View"

    let _ = outputs.displayList.wrappedValue

    print(graph)
}
