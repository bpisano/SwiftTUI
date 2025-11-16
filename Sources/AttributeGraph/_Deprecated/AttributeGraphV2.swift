//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 23/10/2025.
//

//import Foundation
//import Playgrounds

//#Playground("Numbers") {
//    let graph: Graph = .init()
//    graph.makeCurrent()
//
//    @Attribute var x: Int = 10
//    @Attribute var y: Int = 20
//
//    @Attribute var a: Int = 1
//    @Attribute var b: Int = x + y
//    @Attribute var c: Int = a + b
//
//    $a.id = "A"
//    $b.id = "B"
//    $c.id = "C"
//    $x.id = "X"
//    $y.id = "Y"
//
//    print(c)
//    print(graph.description) // Initial
//
//    y = 30
//    print(graph.description) // After changing Y
//    print(c)
//    print(graph.description) // After evaluating C
//}
//
//#Playground("Structs") {
//    struct User {
//        var name: String
//    }
//
//    let graph: Graph = .init()
//    graph.makeCurrent()
//
//    @Attribute var user: User = .init(name: "Alice")
//    @Attribute var userName: String = user.name
//
//    $user.id = "user"
//    $userName.id = "userName"
//
//    print(userName)
//    print(graph.description) // Initial
//
//    user.name = "Bob"
//
//    print(graph.description) // After changing user.name
//
//    print(userName)
//}
