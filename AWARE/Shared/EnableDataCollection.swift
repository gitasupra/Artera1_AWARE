import Combine
import WatchConnectivity

final class EnableDataCollection: ObservableObject {
    var session: WCSession
    let delegate: WCSessionDelegate
    let subject = PassthroughSubject<Int, Never>()
    let heartSubject = PassthroughSubject<(Double, Int), Never>()
    
    @Published private(set) var enableDataCollection: Int = 0
    
    init(session: WCSession = .default) {
        self.delegate = SessionDelegater(enableDataCollectionSubject: subject, heartRateSubject: heartSubject)
        self.session = session
        self.session.delegate = self.delegate
        self.session.activate()
        
        subject
            .receive(on: DispatchQueue.main)
            .assign(to: &$enableDataCollection)
    }
    
    func toggleOn() {
        enableDataCollection = 1
        session.sendMessage(["enableDataCollection": enableDataCollection], replyHandler: nil) { error in
            print(error.localizedDescription)
        }
    }
    
    func toggleOff() {
        enableDataCollection = 0
        session.sendMessage(["enableDataCollection": enableDataCollection], replyHandler: nil) { error in
            print(error.localizedDescription)
        }
    }
}
