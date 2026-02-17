//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 17/02/2026.
//

import Foundation
import Testing
import AttributeGraph

@MainActor
final class ConditionalRule<TrueContent, FalseContent>: Rule {
    enum Storage {
        case trueContent(TrueContent)
        case falseContent(FalseContent)
    }

    private let subgraph: Subgraph = .init()
    private let makeTrueContent: () -> TrueContent
    private let makeFalseContent: () -> FalseContent

    private var storage: Storage?
    private var cachedCondition: Bool?
    private var condition: () -> Bool

    init(
        condition: @autoclosure @escaping () -> Bool,
        trueContent: @escaping () -> TrueContent,
        falseContent: @escaping () -> FalseContent
    ) {
        self.condition = condition
        self.makeTrueContent = trueContent
        self.makeFalseContent = falseContent
    }

    func evaluate() -> Storage {
        let evaluatedCondition: Bool = condition()
        let conditionChanged: Bool = cachedCondition != evaluatedCondition

        if conditionChanged {
            subgraph.clean()
            Graph.current.subgraph = subgraph
            cachedCondition = evaluatedCondition

            if evaluatedCondition {
                storage = .trueContent(makeTrueContent())
            } else {
                storage = .falseContent(makeFalseContent())
            }
        }

        return storage!
    }
}

@MainActor
struct SubgraphTests {
    @Test
    func subgraph() {
        let graph: Graph = .init()
        graph.makeCurrent()

        @Attribute var showContent: Bool = false
        @Attribute var showInnerContent: Bool = false

//        let subgraph: Subgraph = .init(graph: graph)

//        let rule: ConditionalRule<String, String> = .init(
//            condition: showContent,
//            trueContent: {
//                @Attribute var content: String = "Content shown"
//                $content.label = "True content"
//                return content
//            },
//            falseContent: {
//                @Attribute var content: String = "Content hidden"
//                $content.label = "False content"
//                return content
//            }
//        )
        let content = makeConditionalContent(
            condition: showContent,
            trueContent: {
                let innerContent = makeConditionalContent(
                    condition: showInnerContent,
                    trueContent: {
                        "Inner content shown"
                    },
                    falseContent: {
                        "Inner content hidden"
                    }
                )
                switch innerContent.wrappedValue {
                case .trueContent(let value):
                    return value
                case .falseContent(let value):
                    return value
                }
            },
            falseContent: {
                "Content hidden"
            }
        )

        $showContent.label = "@State showContent"
        content.label = "Content"

        print(content.wrappedValue)
        print(graph)

        showContent = true

        print(content.wrappedValue)
        print(graph)

        showContent = true

        print(content.wrappedValue)
        print(graph)
    }
}

@MainActor
func makeConditionalContent(
    condition: @autoclosure @escaping () -> Bool,
    trueContent: @escaping () -> String,
    falseContent: @escaping () -> String
) -> Attribute<ConditionalRule<String, String>.Storage> {
    let rule: ConditionalRule<String, String> = .init(
        condition: condition(),
        trueContent: {
            var content = Attribute {
                trueContent()
            }
            content.label = "True content"
            return content.wrappedValue
        },
        falseContent: {
            var content = Attribute {
                falseContent()
            }
            content.label = "False content"
            return content.wrappedValue
        }
    )
    return Attribute(rule: rule)
}
