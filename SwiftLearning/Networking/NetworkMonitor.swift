import Foundation
import Network
import Combine

@MainActor
final class NetworkMonitor: ObservableObject {
    static let shared = NetworkMonitor()
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    @Published private(set) var isConnected: Bool = true
    @Published private(set) var isInternetReachable: Bool = true {
        didSet {
            if isInternetReachable == false {
                attemptCheckLoop()
            }
        }
    }

    private var isChecking = false

    private init() {
        print("network init")
        
        monitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor in
                guard let self = self else { return }

                self.isConnected = path.status == .satisfied
                print("pathupdatehandler \(path.status) \(self.isInternetReachable)")

                if path.status == .satisfied {
                    InternetTester.verifyInternetConnection { isReachable in
                        Task { @MainActor in
                            self.isInternetReachable = isReachable
                        }
                    }
                } else {
                    self.isInternetReachable = false
                }
            }
        }
        
        monitor.start(queue: queue)
        startPeriodicChecks()
    }

    public func attemptCheckLoop() {
        guard !isChecking else { return }
        isChecking = true
        
        InternetTester.verifyInternetConnection { [weak self] isReachable in
            Task { @MainActor in
                guard let self = self else { return }

                if isReachable {
                    print("isReachable")
                    self.isInternetReachable = true
                    self.isChecking = false
                } else {
                    print("!isReachable")
                    self.isInternetReachable = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.attemptCheckLoop()
                    }
                }
            }
        }
    }

    public func checkConnection() async -> Bool {
        await withCheckedContinuation { continuation in
            InternetTester.verifyInternetConnection { [weak self] isReachable in
                Task { @MainActor in
                    guard let self = self else { return }

                    self.isInternetReachable = isReachable
                    print("checkConnection\(isReachable)")
                    if !isReachable {
                        self.attemptCheckLoop()
                    }

                    continuation.resume(returning: isReachable)
                }
            }
        }
    }
    
    private func startPeriodicChecks() {
        Timer.scheduledTimer(withTimeInterval: 7, repeats: true) { _ in
            InternetTester.verifyInternetConnection { [weak self] isReachable in
                Task { @MainActor in
                    self?.isInternetReachable = isReachable
                }
            }
        }
    }
}
