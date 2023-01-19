//
//  LockerPeripheral.swift
//  locker-test
//
//  Created by Danil Bezuglov on 11/30/22.
//

import CoreBluetooth

protocol CBPeripheralType: AnyObject {}

extension CBPeripheral: CBPeripheralType {}

protocol CBCentralManagerType {
    func connect(peripheral: CBPeripheralType, options: [String: AnyObject]?)
}

extension CBCentralManager: CBCentralManagerType {
    func connect(peripheral: CBPeripheralType, options: [String: AnyObject]?) {
        if let realPeripheral = peripheral as? CBPeripheral {
            connect(realPeripheral, options: options)
        }
    }
}

class CBPeripheralMock: CBPeripheralType {}

class CBCentralManagerMock: CBCentralManagerType {
    var latestPeripheral: CBPeripheralType?

    func connect(peripheral: CBPeripheralType, options: [String : AnyObject]?) {
            latestPeripheral = peripheral
    }
}
