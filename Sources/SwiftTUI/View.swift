//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 30/10/2025.
//

import Foundation
import AttributeGraph
import Playgrounds

public protocol View {
    associatedtype Body: View

    var body: Body { get }
}

public protocol PrimaryView: View {
    associatedtype Body = Never

    func render() -> Attribute<String>
}

extension PrimaryView {
    public var body: Never {
        fatalError("PrimaryView has no body")
    }
}

extension Never: View {
    public var body: Never {
        fatalError("Never has no body")
    }
}

struct EmptyView: View {
    var body: Never {
        fatalError("EmptyView has no body")
    }
}

@resultBuilder
struct ViewBuilder {
    static func buildBlock(_ components: any View...) -> [any View] {
        components
    }
}

// MARK: - Views

struct VStack<each V: View>: PrimaryView {
    let renderingAttribute: Attribute<String>

    init(content: @escaping () -> (repeat each V)) {
        var attributes: [Attribute<String>] = []
        for child in repeat each content() {
            let viewRendering = Attribute<String>(rule: ViewRenderingRule(child))
            viewRendering.label = "\(type(of: child))"
            attributes.append(viewRendering)
        }

        @Attribute var vstackRendering: String = attributes
            .map { $0.wrappedValue }
            .joined(separator: "\n")
        $vstackRendering.label = "VStack_Tuple"
        self.renderingAttribute = $vstackRendering
    }

    func render() -> Attribute<String> {
        renderingAttribute
    }
}

struct Text: PrimaryView {
    let renderingAttribute: Attribute<String>

    init(_ content: @autoclosure @escaping () -> String) {
        @Attribute var textAttr = content()
        $textAttr.label = "String value"
        self.renderingAttribute = $textAttr
    }

    func render() -> Attribute<String> {
        renderingAttribute
    }
}

// MARK: - Test View

struct TestView: View {
    @State var count: Int = 0

    init() {
        _count.attribute.label = "@State count"
    }

    var body: some View {
        VStack {
            (
                Text("\(count)"),
                Text("OK"),
                Subview()
            )
        }
    }
}

struct Subview: View {
    @State var title: String = "Hello"

    init() {
        _title.attribute.label = "@State title"
    }

    var body: some View {
        Text(title)
    }
}


// MARK: - Rules

struct ViewRenderingRule<Content: View>: Rule {
    private let content: Content
    private let renderingAttribute: Attribute<String>

    init(_ content: Content) {
        self.content = content

        if let content = content as? (any PrimaryView) {
            renderingAttribute = content.render()
        } else {
            let contentBody = content.body
            let bodyRendering: Attribute<String> = .init(
                rule: ViewRenderingRule<Content.Body>(contentBody)
            )
            bodyRendering.label = "\(type(of: contentBody))"

            renderingAttribute = bodyRendering
        }
    }

    func evaluate() -> String {
        renderingAttribute.wrappedValue
    }
}

// MARK: - Playground

#Playground {
    let graph: Graph = .init()
    graph.makeCurrent()

    var rootView = TestView()

    let rootRendering = Attribute<String>(rule: ViewRenderingRule(rootView))
    rootRendering.label = "\(type(of: rootView))"

    print(rootRendering.wrappedValue)
    print(graph.description) // avant modification de l’état

    graph.beginTransactionTracking()
    rootView.count += 1

    print(graph.description) // après modification de l’état
    print(rootRendering.wrappedValue)
    print(graph.description) // après réévaluation

    let transaction = graph.endTransactionTracking()
    print(transaction)
}
