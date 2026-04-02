import Foundation

public struct ComputedRule<T>: Rule {
    private let compute: () -> T

    public init(_ compute: @escaping () -> T) {
        self.compute = compute
    }

    public func evaluate() -> T {
        compute()
    }
}
