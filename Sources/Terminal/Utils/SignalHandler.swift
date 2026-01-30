import Foundation

actor SignalHandler {
    private let signalNumber: Int32
    private let handler: @Sendable () async -> Void
    private var source: DispatchSourceSignal?

    init(
        _ signalNumber: Int32,
        operation: sending @escaping @Sendable @isolated(any) () async -> Void
    ) {
        self.signalNumber = signalNumber
        self.handler = operation
        Task {
            await setupSignalHandling()
        }
    }

    private func setupSignalHandling() {
        var action: sigaction = .init()
        sigemptyset(&action.sa_mask)
        action.sa_flags = 0
        sigaction(signalNumber, &action, nil)

        source = DispatchSource.makeSignalSource(signal: signalNumber, queue: .global())
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
