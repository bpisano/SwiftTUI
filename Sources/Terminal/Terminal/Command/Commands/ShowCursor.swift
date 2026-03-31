public struct ShowCursor: Command {
    public init() {}

    public func makeCommand() -> String {
        return "\u{1B}[?25h"
    }
}

extension Command where Self == ShowCursor {
    public static var showCursor: Self {
        .init()
    }
}
