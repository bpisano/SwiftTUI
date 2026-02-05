import Foundation
import Geometry

#if os(macOS)
    import Darwin
#elseif os(Linux)
    import Glibc
#endif

public final class Screen {
    public static let current: Screen = .init()

    public var size: Size { cachedSize }

    public var bounds: Rect { .init(origin: .zero, size: size) }

    public var onSizeChange: ((_ screenSize: Size) -> Void)?

    private var cachedSize: Size = .zero
    private var sizeChangeSignalHandler: SignalHandler?

    package init() {
        cachedSize = getScreenSize() ?? .zero
        sizeChangeSignalHandler = .init(SIGWINCH) { @MainActor [weak self] in
            guard let self else { return }
            if let newSize = self.getScreenSize() {
                self.cachedSize = newSize
                self.onSizeChange?(newSize)
            }
        }
    }

    private func getScreenSize() -> Size? {
        var w: winsize = winsize()
        guard ioctl(STDOUT_FILENO, TIOCGWINSZ, &w) == 0 else { return nil }
        return Size(width: Double(w.ws_col), height: Double(w.ws_row))
    }
}
