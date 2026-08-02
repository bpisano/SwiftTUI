import Foundation

#if os(macOS)
    import Darwin
#elseif os(Linux)
    import Glibc
#endif

@MainActor
public final class Terminal {
    public static let current: Terminal = .init()

    public let screen: Screen = .init()
    public let cursor: Cursor = .init()
    public var onExit: (() -> Void)?

    private var termios: termios = .init()
    private var exitSignalHandler: SignalHandler?

    private init() {
        exitSignalHandler = .init(SIGINT) { @MainActor [weak self] in
            guard let self else { return }
            self.onExit?()
        }
    }

    public static nonisolated func make(command: some Command) -> String {
        command.makeCommand()
    }

    public func enableRawMode() {
        tcgetattr(STDIN_FILENO, &termios)
        var raw: termios = termios
        raw.c_lflag &= ~(.init(ECHO | ICANON | IEXTEN))
        raw.c_iflag &= ~(.init(IXON | ICRNL))
        raw.c_oflag &= ~(.init(OPOST))
        tcsetattr(STDIN_FILENO, TCSAFLUSH, &raw)
    }

    public func disableRawMode() {
        tcsetattr(STDIN_FILENO, TCSAFLUSH, &termios)
    }

    public func enableKeyboardEventReporting() {
        cursor.write("\u{1B}[>23u")
    }

    public func disableKeyboardEventReporting() {
        cursor.write("\u{1B}[<u")
    }
}
