import Combine
import WatchConnectivity

class SessionDelegater: NSObject, WCSessionDelegate {
    let enableDataCollectionSubject: PassthroughSubject<Int, Never>
    let heartRateSubject: PassthroughSubject<(Double, Int), Never>
    
    init(enableDataCollectionSubject: PassthroughSubject<Int, Never>, heartRateSubject: PassthroughSubject<(Double, Int), Never>) {
        self.enableDataCollectionSubject = enableDataCollectionSubject
        self.heartRateSubject = heartRateSubject
        super.init()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        // Protocol comformance only
        // Not needed for this demo
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        DispatchQueue.main.async {
            if let enableDataCollection = message["enableDataCollection"] as? Int {
                self.enableDataCollectionSubject.send(enableDataCollection)
            } else {
                print("There was an error")
            }
        }
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any]) {
        if let lastHeartRate = userInfo["lastHeartRate"] as? Double,
           let heartRateIdx = userInfo["heartRateIdx"] as? Int {
            self.heartRateSubject.send((lastHeartRate, heartRateIdx))
            print("last heart rate: \(lastHeartRate)")
            // Append the received heart rate data to the list
            //heartRateList.append(HeartRateDataPoint(heartRate: lastHeartRate, myIndex: heartRateIdx, id: UUID()))
            
            // You can use heartRateList as needed for your application
            //print("Updated heart rate list:", heartRateList)
        } else {
            print("nooo")
        }
    }
    
    // iOS Protocol comformance
    // Not needed for this demo otherwise
    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("\(#function): activationState = \(session.activationState.rawValue)")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        // Activate the new session after having switched to a new watch.
        session.activate()
    }
    
    func sessionWatchStateDidChange(_ session: WCSession) {
        print("\(#function): activationState = \(session.activationState.rawValue)")
    }
    #endif
}
