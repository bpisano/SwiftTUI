import Foundation

public struct ValueRule<T>: Rule {
    private let compute: () -> T

    public init(_ value: @escaping () -> T) {
        self.compute = value
    }

    public func evaluate() -> T {
        compute()
    }
}
