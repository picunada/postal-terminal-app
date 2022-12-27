//
//  BluetoothManager.swift
//  locker-test
//
//  Created by Danil Bezuglov on 10/27/22.
//

import Combine
import CoreBluetooth

final class BluetoothManager: NSObject {
    
    static let shared: BluetoothManager = .init()
    
    private var centralManager: CBCentralManager!
    
    var stateSubject: PassthroughSubject<CBManagerState, Never> = .init()
    var peripheralSubject: PassthroughSubject<CBPeripheral, Never> = .init()
    var servicesSubject: PassthroughSubject<[CBService], Never> = .init()
    var characteristicsSubject: PassthroughSubject<(CBService, [CBCharacteristic]), Never> = .init()
    var networksSubject: PassthroughSubject<WifiNetworks, Never> = .init()
    var responseSubject: PassthroughSubject<BLEResponse, Never> = .init()
    var serialSubject: PassthroughSubject<String, Never> = .init()
    
    func start() {
        centralManager = .init(delegate: self, queue: .main)
    }
    
    func scan(services: [CBUUID]?) {
        centralManager.scanForPeripherals(withServices: services ?? nil)
    }
    
    func connect(_ peripheral: CBPeripheral) {
        centralManager.stopScan()
        peripheral.delegate = self
        centralManager.connect(peripheral)
    }
}

extension BluetoothManager: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        stateSubject.send(central.state)
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        peripheralSubject.send(peripheral)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.discoverServices(nil)
    }
}

extension BluetoothManager: CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else {
            return
        }
        servicesSubject.send(services)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else {
            return
        }
        characteristicsSubject.send((service, characteristics))
    }

    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        peripheral.readValue(for: characteristic)
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let string = String(data: (characteristic.value)!, encoding: .utf8) {
            print(string)
            let jsonData = Data(string.utf8)
            let decoder = JSONDecoder()

            do {
                let networks = try decoder.decode(WifiNetworks.self, from: jsonData)
                networksSubject.send(networks)
            } catch {
                print(error)
            }
            
            do {
                let response = try decoder.decode(BLEResponse.self, from: jsonData)
                responseSubject.send(response)
            } catch {
                print(error)
            }
            
            self.serialSubject.send(string)
        } else {
            print("not a valid UTF-8 sequence")
        }
    }
}
