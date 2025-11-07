// Minimal WatchConnectivity sample for the WatchKit extension
import WatchConnectivity

class WatchSessionManager: NSObject, WCSessionDelegate {
    static let shared = WatchSessionManager()
    private let session = WCSession.default

    func start() {
        session.delegate = self
        session.activate()
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        // handle activation
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        // Example message: ["type":"heart_rate", "value": 78, "timestamp": "..."]
        NotificationCenter.default.post(name: Notification.Name("WatchMessageReceived"), object: nil, userInfo: message)
    }

    // Other delegate methods omitted for brevity
}
