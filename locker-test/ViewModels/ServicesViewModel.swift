//
//  ServicesViewModel.swift
//  locker-test
//
//  Created by Danil Bezuglov on 12/30/22.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift

struct DeliveryService: Codable, Identifiable, Hashable {
    @DocumentID var id: String?
    var name: String
    var imageURL: String
        
}


class ServicesViewModel: ObservableObject {
    
    private var db = Firestore.firestore()
    
    @Published var services: [DeliveryService] = .init()
    
    
    
    func fetchServices() {
        db.collection("services").getDocuments() { [weak self] (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                guard let documents = querySnapshot?.documents else { return }
                
                self?.services = documents.compactMap({ doc in
                    let result = Result { try doc.data(as: DeliveryService.self) }
                    
                    switch result {
                    case .success(let service):
                        return service
                    case .failure(let err):
                        print("document error: \(err)")
                        return nil
                    }
                })
            }
        }

    }
}
