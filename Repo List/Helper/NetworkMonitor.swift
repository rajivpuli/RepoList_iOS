//
//  NetworkMonitor.swift
//  Repo List
//
//  Created by Rajiv Puli on 12/08/21.
//

import Network

protocol NetworkMonitorDelegate {
    func networkStatusChanged(status: Bool)
}

class NetworkMonitor: NSObject {
    
    static let shared = NetworkMonitor()
    var delegate: NetworkMonitorDelegate?
    
    let monitor = NWPathMonitor()
    private var status: NWPath.Status = .requiresConnection
    var isReachable: Bool { status == .satisfied }
    var isReachableOnCellular: Bool = true
    var isMonitorStarted: Bool = false
    
    func startMonitoring() {
        isMonitorStarted = true
        monitor.pathUpdateHandler = { [weak self] path in
            self?.status = path.status
            self?.isReachableOnCellular = path.isExpensive
            
            if path.status == .satisfied {
                print("We're connected!")
                // post connected notification
            } else {
                print("No connection.")
                // post disconnected notification
            }
//            print(path.isExpensive)
            self?.delegate?.networkStatusChanged(status: self?.isReachable ?? false)
        }
        
        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor.start(queue: queue)
    }
    
    func stopMonitoring() {
        monitor.cancel()
        isMonitorStarted = false
    }
}
