import AppKit

struct AudioService {
    static let shared = AudioService()

    func playSound(_ name: String = "Tink") {
        NSSound(named: name)?.play()
    }
}
