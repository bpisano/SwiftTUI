import Foundation

public protocol Rule {
    associatedtype Value

    func evaluate() -> Value
}
