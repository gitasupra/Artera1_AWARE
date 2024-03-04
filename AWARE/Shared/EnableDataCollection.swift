import Combine
import WatchConnectivity

final class EnableDataCollection: ObservableObject {
    var session: WCSession
    let delegate: WCSessionDelegate
    var cancellables = Set<AnyCancellable>()
    let enableDataSubject = PassthroughSubject<Int, Never>()
    let heartRateSubject = PassthroughSubject<(Double, Int), Never>()
    let newIntoxLevelSubject=PassthroughSubject<Int, Never>()
    let maxNrRetries = 5
    var availableRetries : Int
    
    @Published private(set) var enableDataCollection: Int = 0
    @Published private(set) var heartRateList: [(Double, Int)] = []
    @Published private(set) var newIntoxLevel: Int = 0
    
    init(session: WCSession = .default) {
        availableRetries=maxNrRetries
        self.delegate = SessionDelegater(enableDataCollectionSubject: enableDataSubject, heartRateSubject: heartRateSubject, newIntoxLevelSubject: newIntoxLevelSubject)
        self.session = session
        self.session.delegate = self.delegate
        self.session.activate()
        
        enableDataSubject
            .receive(on: DispatchQueue.main)
            .assign(to: &$enableDataCollection)
        
        heartRateSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] receivedHeartRate in
                self?.heartRateList.append(receivedHeartRate)
//                print("append to heart rate")
            }
            .store(in: &cancellables)
        
        newIntoxLevelSubject
            .receive(on: DispatchQueue.main)
            .assign(to: &$newIntoxLevel)
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
    
    func sendLevelToWatch(level: Int){
        print("send level to watch")
        newIntoxLevel=level
        session.sendMessage(["newIntoxLevel": newIntoxLevel], replyHandler: nil) { error in
            print(error.localizedDescription)
        }
//        trySendingMessageToWatch(["newIntoxLevel": newIntoxLevel] as [String: AnyObject])
            //            print(error.localizedDescription)
    }
    
    func trySendingMessageToWatch(_ message: [String: AnyObject]) {
        session.sendMessage(message,
                            replyHandler: nil,
                            errorHandler: { error in
            print("sending message to watch failed: error: \(error)")
            let nsError = error as NSError
            if nsError.domain == "WCErrorDomain" && nsError.code == 7007 && self.availableRetries > 0 {
                self.availableRetries = self.availableRetries - 1
                let randomDelay = Double.random(in: 1.0...2.0)
                DispatchQueue.main.asyncAfter(deadline: .now() + randomDelay, execute: {
                    self.trySendingMessageToWatch(message)
                })
            } else {
                print("error")
            }
        })
    }
    
}
