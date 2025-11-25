public struct ClearScreen: Command {
    public init() {}

    public func makeCommand() -> String {
        return "\u{1B}[2J"
    }
}

extension Command where Self == ClearScreen {
    public static var clearScreen: ClearScreen {
        return ClearScreen()
    }
}
