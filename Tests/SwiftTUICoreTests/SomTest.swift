//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 05/03/2026.
//

import AppKit
import AttributeGraph
import Geometry
import Testing

//@Test
//func main() {
//    @Attribute("Screen position") var position: Point = .zero
//    @Attribute("Screen size") var size = Size(width: 2, height: 20)
//    let inputs = ViewInputs(
//        position: $position,
//        size: $size
//    )
//    @Attribute var view = VStack(
//        TupleView(
//            Text("He"),
//            Text("ll")
//        )
//    )
//    $view.label = "\(type(of: view))"
//
//    let outputs = type(of: view).makeView($view, inputs: inputs)
//
//    _ = outputs.displayList.wrappedValue
//
//    copyToClipboard(Graph.current.description)
//}
//
//@Test
//func forEach() {
//    @Attribute("Screen position") var position: Point = .zero
//    @Attribute("Screen size") var size = Size(width: 10, height: 20)
//    let inputs = ViewInputs(
//        position: $position,
//        size: $size
//    )
//    @Attribute("Users") var users: [User] = [
//        User(id: 1, name: "Alice"),
//        User(id: 2, name: "Bob"),
//    ]
//    @Attribute var view = VStack(
//        ForEach(users, id: \.id) { user in
//            Text(user.name)
//                .frame(width: 2)
//        }
//    )
//    $view.label = "\(type(of: view))"
//
//    let outputs = type(of: view).makeView($view, inputs: inputs)
//
//    _ = outputs.displayList.wrappedValue
//
//    users = [
//        User(id: 2, name: "Bob"),
//        User(id: 1, name: "Alice"),
//    ]
//
//    _ = outputs.displayList.wrappedValue
//
//    copyToClipboard(Graph.current.description)
//}
//
//@Test
//func frame() {
//    @Attribute("Screen position") var position: Point = .zero
//    @Attribute("Screen size") var size = Size(width: 20, height: 20)
//    let inputs = ViewInputs(
//        position: $position,
//        size: $size
//    )
//    @Attribute var view = Text("Hello world")
//        .frame(width: 2)
//    $view.label = "\(type(of: view))"
//
//    let outputs = type(of: view).makeView($view, inputs: inputs)
//
//    _ = outputs.displayList.wrappedValue
//
//    copyToClipboard(Graph.current.description)
//}
//
//@Test
//func `Custom modifier`() {
//    @Attribute("Screen position") var position: Point = .zero
//    @Attribute("Screen size") var size = Size(width: 20, height: 20)
//    let inputs = ViewInputs(
//        position: $position,
//        size: $size
//    )
//    @Attribute var view = Text("Hello world")
//        .frame(width: 2)
//    $view.label = "\(type(of: view))"
//
//    let outputs = type(of: view).makeView($view, inputs: inputs)
//
//    _ = outputs.displayList.wrappedValue
//
//    copyToClipboard(Graph.current.description)
//}
//
//private func copyToClipboard(_ string: String) {
//    let pasteboard: NSPasteboard = .general
//    pasteboard.clearContents()
//    pasteboard.setString(string, forType: .string)
//}
//
//private struct User: Identifiable {
//    let id: Int
//    let name: String
//}
//
//extension User: CustomStringConvertible {
//    var description: String {
//        name
//    }
//}

//struct CustomFrameViewModifier: ViewModifier {
//    func body(content: Content) -> some View {
//        content.frame(width: 2)
//    }
//}
