//
//  TelemetryViewModel.swift
//  locker-test
//
//  Created by Danil Bezuglov on 12/27/22.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift

// MARK: Telemetry Model

struct LockerTelemetry: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var battery: String
    var lock_status: String
}


class TelemetryViewModel: ObservableObject {
    
    let db = Firestore.firestore()
    
    @Published var telemetry: LockerTelemetry?
    
    private var listenerRegistration: ListenerRegistration?
    
    func subscribe(user: LockerUser) {
        self.listenerRegistration = db.collection("telemetry").document(user.lockerId!)
            .addSnapshotListener {[weak self] (snap, error) in
                guard let document = snap else {
                        print("Error fetching document: \(error!)")
                        return
                      }
                let result = Result { try document.data(as: LockerTelemetry.self) }
                
                switch result {
                case .success(let telemetry):
                    print(telemetry)
                    self?.telemetry = telemetry
                case .failure(_): break
//                    self?.error = error
                }
                
            }
    }
    
    func unsubscribe() {
        listenerRegistration?.remove()
    }
}
