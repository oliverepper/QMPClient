import Foundation
import Network

@main
struct QMPClient {
    private static let sigintSource = registerSIGINT()

    static func main() {
        _ = sigintSource
        print("Start")
        client()
        dispatchMain()
    }
}

private func registerSIGINT() -> DispatchSourceSignal {
    signal(SIGINT, SIG_IGN)

    let source = DispatchSource.makeSignalSource(signal: SIGINT, queue: .main)
    source.setEventHandler {
        print("\nDone")
        exit(EXIT_SUCCESS)
    }
    source.resume()

    return source
}

func receiveLoop(_ connection: NWConnection) {
    connection.receiveMessage { content, contentContext, isComplete, error in
        if let error { fatalError(error.localizedDescription) }
        guard let content else {
            print(isComplete)
            return
        }

        guard let metadata = contentContext?.protocolMetadata(
            definition: LineFramer.definition
        ) as? NWProtocolFramer.Message,
              let timestamp = metadata.timestamp,
              let line = String(data: content, encoding: .utf8)?.trimmingCharacters(in: .newlines) else {
            return
        }

        print("\(timestamp) received: \(line)")

        receiveLoop(connection)
    }
}

private func client() {
    let sockPath = "/tmp/my.sock"
    let params = NWParameters(tls: nil)
    let lineframer = NWProtocolFramer.Options(definition: LineFramer.definition)
    params.defaultProtocolStack.applicationProtocols.insert(lineframer, at: 0)

    let connection = NWConnection(to: .unix(path: sockPath), using: params)

    connection.stateUpdateHandler = { state in
        switch state {
        case .setup:
            print("setup")
        case .waiting(let nWError):
            print("waiting: " + nWError.localizedDescription)
        case .preparing:
            print("preparing")
        case .ready:
            print("ready")
        case .failed(let nWError):
            print("error: " + nWError.localizedDescription)
        case .cancelled:
            print("cancelled")
        @unknown default:
            fatalError()
        }
    }

    connection.start(queue: .init(label: "Demo"))

    receiveLoop(connection)
}
