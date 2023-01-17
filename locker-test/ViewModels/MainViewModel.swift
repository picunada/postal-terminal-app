//
//  MainViewModel.swift
//  locker-test
//
//  Created by Danil Bezuglov on 10/31/22.
//

import SwiftUI
import CoreBluetooth
import Combine

final class MainViewModel: ObservableObject {

    @Published var state: CBManagerState = .unknown {
        didSet {
            update(with: state)
        }
    }
    @AppStorage("identifier") private var identifier: String = ""
    @Published var peripheral: CBPeripheral?

    private lazy var manager: BluetoothManager = .shared
    private lazy var cancellables: Set<AnyCancellable> = .init()

    //MARK: - Lifecycle
    
    deinit {
        cancellables.removeAll()
    }
    
    func start() {
        manager.stateSubject.sink { [weak self] state in
            self?.state = state
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
            .first()
            .sink {[weak self] peripheral in
                withAnimation(.default.delay(1)) {
                    self?.peripheral = peripheral
                }
            }
            .store(in: &cancellables)
        manager.scan(services: Constants.serviceUUIDs)
    }
    
    
}
