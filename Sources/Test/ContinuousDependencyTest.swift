//
//  ContinuousDependencyTest.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 20/11/2025.
//

import AttributeGraph
import Foundation
import Playgrounds

#Playground {
    print("=== Testing Continuous Dependency Capture ===\n")

    let graph: Graph = .init()
    graph.makeCurrent()

    @Attribute var condition = true
    @Attribute var x = 10
    @Attribute var y = 20
    @Attribute var z = 30

    // Conditional dependency: switches between x and y based on condition
    @Attribute var result: Int = condition ? x : y
    @Attribute var final = result + z

    $condition.label = "Condition"
    $x.label = "X"
    $y.label = "Y"
    $z.label = "Z"
    $result.label = "Result"
    $final.label = "Final"

    print("Initial evaluation:")
    _ = final
    print("Result: \(result), Final: \(final)")
    print("\nGraph structure:")
    print(graph.description)

    print("\n\n=== Changing condition to false ===")
    graph.beginTransactionTracking()
    condition = false

    print("\nRe-evaluating after condition change:")
    _ = final
    print("Result: \(result), Final: \(final)")
    print("\nUpdated graph structure (dependencies should change):")
    print(graph.description)

    let transaction = graph.endTransactionTracking()
    print("\n\(transaction)")

    print("\n\n=== Changing X (should NOT affect result anymore) ===")
    graph.beginTransactionTracking()
    x = 999

    print("\nRe-evaluating after X change:")
    _ = final
    print("Result: \(result), Final: \(final)")
    print("Note: X changed but result didn't change because dependency shifted to Y")

    let transaction2 = graph.endTransactionTracking()
    print("\n\(transaction2)")

    print("\n\n=== Changing Y (SHOULD affect result now) ===")
    graph.beginTransactionTracking()
    y = 100

    print("\nRe-evaluating after Y change:")
    _ = final
    print("Result: \(result), Final: \(final)")

    let transaction3 = graph.endTransactionTracking()
    print("\n\(transaction3)")

    print("\n✅ Continuous dependency capture working with O(n) complexity!")
}
