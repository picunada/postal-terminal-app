//
//  ServicesViewModel.swift
//  locker-test
//
//  Created by Danil Bezuglov on 12/30/22.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift
import FirebaseStorage

struct DeliveryService: Codable, Identifiable {
    @DocumentID var id: String?
    var name: String
    var imageURL: String
    
    func getImage() -> UIImage? {
        let storageRef = Storage.storage().reference()
        let fileRef = storageRef.child(self.imageURL)
        var image: UIImage?
        
        fileRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
          if let error = error {
              print(error)
          } else {
            // Data for "images/island.jpg" is returned
            print(dataz)
            image = UIImage(data: data!)
          }
        }
        
        return image
    }
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
