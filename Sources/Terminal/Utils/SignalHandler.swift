import Foundation

actor SignalHandler {
    private let handler: @Sendable () async -> Void
    private var source: DispatchSourceSignal?

    init(
        operation: sending @escaping @Sendable @isolated(any) () async -> Void
    ) {
        self.handler = operation
        Task {
            await setupSignalHandling()
        }
    }

    private func setupSignalHandling() {
        signal(SIGWINCH, SIG_IGN)

        source = DispatchSource.makeSignalSource(signal: SIGWINCH, queue: .global())
        source?.setEventHandler { [handler] in
            Task {
                await handler()
            }
        }
        source?.resume()
    }

    func stop() {
        source?.cancel()
        source = nil
    }
}
