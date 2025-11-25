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
    public var sizes: AsyncStream<Size> { getResizeStream() }

    public var bounds: Rect { .init(origin: .zero, size: size) }

    private var cachedSize: Size = .zero

    package init() {
        cachedSize = getScreenSize() ?? .zero
    }

    private func getScreenSize() -> Size? {
        var w: winsize = winsize()
        guard ioctl(STDOUT_FILENO, TIOCGWINSZ, &w) == 0 else { return nil }
        return Size(width: Double(w.ws_col), height: Double(w.ws_row))
    }

    private func getResizeStream() -> AsyncStream<Size> {
        AsyncStream { [weak self] continuation in
            guard let self else {
                continuation.finish()
                return
            }

            let signalHandler = SignalHandler { @MainActor [weak self] in
                guard let self else { return }
                if let size = self.getScreenSize() {
                    self.cachedSize = size
                    continuation.yield(size)
                }
            }

            continuation.onTermination = { _ in
                Task {
                    await signalHandler.stop()
                }
            }
        }
    }
}
