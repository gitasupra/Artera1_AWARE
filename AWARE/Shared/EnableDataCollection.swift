import Combine
import WatchConnectivity

final class EnableDataCollection: ObservableObject {
    var session: WCSession
    let delegate: WCSessionDelegate
    var cancellables = Set<AnyCancellable>()
    let enableDataSubject = PassthroughSubject<Int, Never>()
    let heartRateSubject = PassthroughSubject<(Double, Int), Never>()
    
    @Published private(set) var enableDataCollection: Int = 0
    @Published private(set) var heartRateList: [(Double, Int)] = []
    
    init(session: WCSession = .default) {
        self.delegate = SessionDelegater(enableDataCollectionSubject: enableDataSubject, heartRateSubject: heartRateSubject)
        self.session = session
        self.session.delegate = self.delegate
        self.session.activate()
        
        enableDataSubject
            .receive(on: DispatchQueue.main)
            .assign(to: &$enableDataCollection)
        
        heartRateSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] receivedHeartRate in
                print("appended to heartRateList, now have \(self?.heartRateList.count)")
                self?.heartRateList.append(receivedHeartRate)
            }
            .store(in: &cancellables)
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
