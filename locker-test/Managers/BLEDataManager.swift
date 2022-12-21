//
//  BLEDataManager.swift
//  locker-test
//
//  Created by Danil Bezuglov on 12/1/22.
//

import Foundation
import CoreBluetooth


enum ResponseError: LocalizedError {
    case firebaseError
    case wifiError
    

    var errorDescription: String? {
        switch self {
        case .firebaseError:
            return "Firebase connection error"
        case .wifiError:
            return "Wi-Fi connection error"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .firebaseError:
            return "Firebase connection error maybe caused by Illia"
        case .wifiError:
            return "Wi-Fi connnection error maybe caused because of wrong password"
        }
    }
}

struct BLEData: Encodable {
    var command: String = "get"
    var SSID: String?
    var password: String?
    var fb_login: String?
    var fb_password: String?
    var fb_user_id: String?
}

struct WifiNetwork: Codable, Hashable, Identifiable {
    var SSID: String
    var rssi: Int
    var isOpen: Int
    
    var id: String {
            SSID
        }
}

struct BLEResponse: Codable {
    var status: String
    var reason: String?
    
    var error: ResponseError? {
        if let reason = reason {
            if reason == "firebase_init_error" {
                return ResponseError.firebaseError
            }
            if reason == "wifi_connection_error" {
                return ResponseError.wifiError
            }
        }
        return nil
    }
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
