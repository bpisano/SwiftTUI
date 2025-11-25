public final class Terminal {
    static let current: Terminal = .init()

    public let screen: Screen = .init()
    public let cursor: Cursor = .init()

    private init() {}

    public static func make(command: some Command) -> String {
        return command.makeCommand()
    }
}
