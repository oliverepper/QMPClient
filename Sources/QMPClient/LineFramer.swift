import Foundation
import Network

final class LineFramer: NWProtocolFramerImplementation {

    static let definition = NWProtocolFramer.Definition(implementation: LineFramer.self)

    static var label: String { "LineFramer" }

    init(framer: NWProtocolFramer.Instance) {}

    func start(framer: NWProtocolFramer.Instance) -> NWProtocolFramer.StartResult { return .ready }
    func wakeup(framer: NWProtocolFramer.Instance) {}
    func stop(framer: NWProtocolFramer.Instance) -> Bool { return true }
    func cleanup(framer: NWProtocolFramer.Instance) {}

    func handleInput(framer: NWProtocolFramer.Instance) -> Int {
        #if DEBUG
        print("handleInput called")
        #endif
        while true {
            var deliver = 0
            _ = framer.parseInput(minimumIncompleteLength: 1, maximumLength: .max) { buffer, isComplete in
                guard let buffer, !buffer.isEmpty else { return 0 }

                #if DEBUG
                let hex = buffer.map { String(format: "%02x", $0) }
                print(hex)
                #endif

                if let index = buffer.firstIndex(of: 0x0A) {
                    deliver = index + 1
                }

                return 0
            }

            guard deliver > 0 else {
                #if DEBUG
                print("No complete line found, requesting more data")
                #endif
                return 0
            }

            let message = NWProtocolFramer.Message(definition: Self.definition)
            message.timestamp = Date.now

            if !framer.deliverInputNoCopy(length: deliver, message: message, isComplete: true) {
                #if DEBUG
                print("Message will be delivered, once more data arravies")
                #endif
                return 0
            }

            #if DEBUG
            print("End of loop reached, going to loop")
            #endif
        }
    }
    
    func handleOutput(
        framer: NWProtocolFramer.Instance,
        message: NWProtocolFramer.Message, messageLength: Int,
        isComplete: Bool
    ) {}
}
