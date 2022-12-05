//
//  BluetoothViewModel.swift
//  locker-test
//
//  Created by Danil Bezuglov on 10/27/22.
//

import SwiftUI
import CoreBluetooth
import Combine

enum Constants {
    static let ServiceUUID: CBUUID = .init(string: "4fafc201-1fb5-459e-8fcc-c5c9c331914b")
    static let SerialCharacteristicsUUID: CBUUID = .init(string: "2a25")
    static let serviceUUIDs: [CBUUID] = [ServiceUUID]
    static let WirelessNetworksCharacteristicUUID: CBUUID = .init(string: "cc0f4335-002d-4233-a0ff-44d9934a54de")
    static let WirelessSetCharacteristicUUID: CBUUID = .init(string: "ff5e2d84-730e-40e1-ae6a-ca9cc15a8b07")
}


final class DeviceViewModel: ObservableObject {
    
    @AppStorage("identifier") var identifier: String = ""
    @Published var state: CBManagerState = .unknown
    @Published var peripheral: CBPeripheral
    @Published var networks: WifiNetworks?

    private lazy var manager: BluetoothManager = .shared
    private lazy var cancellables: Set<AnyCancellable> = .init()
    var serialNumberCharacteristic: CBCharacteristic?
    var WirelessNetworksCharacteristic: CBCharacteristic?
    
    //MARK: - Lifecycle
    
    init(peripheral: CBPeripheral) {
        self.peripheral = peripheral
    }
    
    
    deinit {
        cancellables.removeAll()
    }
    
    func connect() -> Void {
        manager.servicesSubject
            .map { $0.filter { Constants.serviceUUIDs.contains($0.uuid) } }
            .sink { [weak self] services in
                services.forEach { service in
                    self?.peripheral.discoverCharacteristics(nil, for: service)
                }
            }
            .store(in: &cancellables)
        
        manager.characteristicsSubject
            .filter { $0.0.uuid == Constants.ServiceUUID }
            .compactMap { $0.1.first(where: \.uuid == Constants.SerialCharacteristicsUUID) }
            .sink { [weak self] characteristic in
                self?.serialNumberCharacteristic = characteristic
            }
            .store(in: &cancellables)
        
        manager.characteristicsSubject
            .filter { $0.0.uuid == Constants.ServiceUUID }
            .compactMap { $0.1.first(where: \.uuid == Constants.WirelessNetworksCharacteristicUUID) }
            .sink { [weak self] characteristic in
                self?.WirelessNetworksCharacteristic = characteristic
            }
            .store(in: &cancellables)
        
        manager.networksSubject
            .sink { [weak self] wifiNetworks in
                self?.networks = wifiNetworks
            }
            .store(in: &cancellables)
        
        manager.connect(self.peripheral)
    }
    
    func write(_ data: Data) {  
        guard let characteristic = WirelessNetworksCharacteristic else {
            return
        }
        print(String(data: data, encoding: .utf8))
        peripheral.writeValue(data, for: characteristic, type: .withResponse)
        print(data)
    }
}

func ==<Root, Value: Equatable>(lhs: KeyPath<Root, Value>, rhs: Value) -> (Root) -> Bool {
    { $0[keyPath: lhs] == rhs }
}

func ==<Root, Value: Equatable>(lhs: KeyPath<Root, Value>, rhs: Value?) -> (Root) -> Bool {
    { $0[keyPath: lhs] == rhs }
}
