import Foundation

public protocol StatefulRule: Rule {
    func update() -> Value
}

public extension StatefulRule {
    func evaluate() -> Value {
        update()
    }
}
