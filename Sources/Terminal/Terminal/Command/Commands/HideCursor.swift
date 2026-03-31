public struct HideCursor: Command {
    public init() {}

    public func makeCommand() -> String {
        return "\u{1B}[?25l"
    }
}

extension Command where Self == HideCursor {
    public static var hideCursor: Self {
        .init()
    }
}
