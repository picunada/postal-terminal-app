//
//  BLEDataManager.swift
//  locker-test
//
//  Created by Danil Bezuglov on 12/1/22.
//

import Foundation
import CoreBluetooth


struct BLEData: Encodable {
    var command: String = "get"
    var SSID: String?
    var password: String?
    var fb_login: String?
    var fb_password: String?
}

struct WifiNetwork: Codable, Hashable {
    var SSID: String
    var rssi: Int
    var isOpen: Int
}

struct WifiNetworks: Codable {
    var networks: [WifiNetwork]
}

extension BLEData {
    func toData() -> Data? {
        do {
            let jsonData = try JSONEncoder().encode(self)
            let jsonString: String = String(data: jsonData, encoding: .utf8)!
            let data: Data = Data(jsonString.utf8)
            return data
        } catch {
            print(error)
            return nil
        }
    }
}
