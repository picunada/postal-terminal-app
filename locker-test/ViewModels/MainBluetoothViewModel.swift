//
//  MainBluetoothViewModel.swift
//  locker-test
//
//  Created by Danil Bezuglov on 12/1/22.
//

import SwiftUI
import CoreBluetooth
import Combine

final class MainBluetoothViewModel: ObservableObject {
    
    @Published var state: CBManagerState = .unknown {
            didSet {
                update(with: state)
            }
        }
    @AppStorage("identifier") private var identifier: String = ""
    @Published var peripheral: CBPeripheral?
    @Published var connectionState: ConnectionState = .idle

    private lazy var manager: BluetoothManager = .shared
    private lazy var cancellables: Set<AnyCancellable> = .init()

    //MARK: - Lifecycle

    func start() {
        manager.stateSubject.sink { [weak self] state in
            self?.state = state
            print(state)
        }
        .store(in: &cancellables)
        manager.start()
    }

    //MARK: - Private
    
    private func update(with state: CBManagerState) {
        guard peripheral == nil else {
            return
        }
        guard state == .poweredOn else {
            return
        }
        manager.peripheralSubject
            .sink { [weak self] in
                self?.peripheral = $0
                print($0)
            }
            .store(in: &cancellables)
        manager.scan(services: Constants.serviceUUIDs)
    }
    
}
