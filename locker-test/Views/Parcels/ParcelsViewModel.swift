//
//  ParcelsViewModel.swift
//  locker-test
//
//  Created by Danil Bezuglov on 10/16/22.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

struct Parcel: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var serviceName: String
    var trackingNumber: String
    var estimatedDeliveryDate: ClosedRange<Date>
    
    var dictionary: [String: Any] {
            let data = (try? JSONEncoder().encode(self)) ?? Data()
            return (try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]) ?? [:]
        }
}

class ParcelViewModel: ObservableObject {
    
    @Published var expectedParcels: [Parcel] = [Parcel]()
    @Published var receivedParcels: [Parcel] = [Parcel]()
    @Published var errorMessage: String?
    
    private var db = Firestore.firestore()
    private var expectedListenerRegistration: ListenerRegistration?
    private var receivedListenerRegistration: ListenerRegistration?
      
    public func unsubscribe() {
      if expectedListenerRegistration != nil {
          expectedListenerRegistration?.remove()
          expectedListenerRegistration = nil
      }
        if receivedListenerRegistration != nil {
            receivedListenerRegistration?.remove()
            receivedListenerRegistration = nil
        }
    }
    
    func subscribe(user: LockerUser) {
        if expectedListenerRegistration == nil {
            expectedListenerRegistration = db.collection("parcels/\(user.lockerId!)/expected")
                .addSnapshotListener { [weak self] (querySnapshot, error) in
                  guard let documents = querySnapshot?.documents else {
                    self?.errorMessage = "No documents in 'expected' collection"
                    return
                  }
                  
                  self?.expectedParcels = documents.compactMap { queryDocumentSnapshot in
                    let result = Result { try queryDocumentSnapshot.data(as: Parcel.self) }
                    
                    switch result {
                    case .success(let parcel):
                      return parcel
                    case .failure(let error):
                      // A Book value could not be initialized from the DocumentSnapshot.
                      switch error {
                      case DecodingError.typeMismatch(_, let context):
                        self?.errorMessage = "\(error.localizedDescription): \(context.debugDescription)"
                      case DecodingError.valueNotFound(_, let context):
                        self?.errorMessage = "\(error.localizedDescription): \(context.debugDescription)"
                      case DecodingError.keyNotFound(_, let context):
                        self?.errorMessage = "\(error.localizedDescription): \(context.debugDescription)"
                      case DecodingError.dataCorrupted(let key):
                        self?.errorMessage = "\(error.localizedDescription): \(key)"
                      default:
                        self?.errorMessage = "Error decoding document: \(error.localizedDescription)"
                      }
                      return nil
                    }
                  }
                }
            }
        if receivedListenerRegistration == nil {
            receivedListenerRegistration = db.collection("parcels/\(user.lockerId!)/received")
                .addSnapshotListener { [weak self] (querySnapshot, error) in
                  guard let documents = querySnapshot?.documents else {
                    self?.errorMessage = "No documents in 'received' collection"
                    return
                  }
                  
                  self?.receivedParcels = documents.compactMap { queryDocumentSnapshot in
                    let result = Result { try queryDocumentSnapshot.data(as: Parcel.self) }
                    
                    switch result {
                    case .success(let parcel):
                      return parcel
                    case .failure(let error):
                      // A Book value could not be initialized from the DocumentSnapshot.
                      switch error {
                      case DecodingError.typeMismatch(_, let context):
                        self?.errorMessage = "\(error.localizedDescription): \(context.debugDescription)"
                      case DecodingError.valueNotFound(_, let context):
                        self?.errorMessage = "\(error.localizedDescription): \(context.debugDescription)"
                      case DecodingError.keyNotFound(_, let context):
                        self?.errorMessage = "\(error.localizedDescription): \(context.debugDescription)"
                      case DecodingError.dataCorrupted(let key):
                        self?.errorMessage = "\(error.localizedDescription): \(key)"
                      default:
                        self?.errorMessage = "Error decoding document: \(error.localizedDescription)"
                      }
                      return nil
                    }
                  }
                }
            }
    }
    
    func createParcel(parcel: Parcel, user: LockerUser) {
        let collectionRef = db.collection("parcels/\(user.lockerId!)/expected")
        do {
          let newDocReference = try collectionRef.addDocument(from: parcel)
          print("Parcel stored with new document reference: \(newDocReference)")
        }
        catch {
          print(error)
        }
      }
    
    func deleteParcel(parcel: Parcel, user: LockerUser, type: String) {
        
        if type == "expected" {
            db.collection("parcels/\(user.lockerId!)/expected").document(parcel.id!).delete() { err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("Document successfully removed!")
                }
            }
        } else {
            db.collection("parcels/\(user.lockerId!)/received").document(parcel.id!).delete() { err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("Document successfully removed!")
                }
            }
        }
        
    }
}
