//
//  KeysViewModel.swift
//  locker-test
//
//  Created by Danil Bezuglov on 10/17/22.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

struct LockerKey: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var keyName: String
    var isOneTime: Bool
    var expirationDate: Date?
    
    var dictionary: [String: Any] {
            let data = (try? JSONEncoder().encode(self)) ?? Data()
            return (try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]) ?? [:]
        }
}

class KeysViewModel: ObservableObject {
    @Published var activeKeys: [LockerKey] = [LockerKey]()
    @Published var inactiveKeys: [LockerKey] = [LockerKey]()
    @Published var errorMessage: String?
    
    private var db = Firestore.firestore()
    private var activeListenerRegistration: ListenerRegistration?
    private var inactiveListenerRegistration: ListenerRegistration?
    
    
    public func unsubscribe() {
      if activeListenerRegistration != nil {
          activeListenerRegistration?.remove()
          activeListenerRegistration = nil
      }
        if inactiveListenerRegistration != nil {
            inactiveListenerRegistration?.remove()
            inactiveListenerRegistration = nil
        }
    }
    
    func subscribe(user: LockerUser) {
        if activeListenerRegistration == nil {
            activeListenerRegistration = db.collection("keys/\(user.lockerId)/active")
                .addSnapshotListener { [weak self] (querySnapshot, error) in
                  guard let documents = querySnapshot?.documents else {
                    self?.errorMessage = "No documents in 'active' collection"
                    return
                  }
                  
                  self?.activeKeys = documents.compactMap { queryDocumentSnapshot in
                    let result = Result { try queryDocumentSnapshot.data(as: LockerKey.self) }
                    
                    switch result {
                    case .success(let key):
                      return key
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
        if inactiveListenerRegistration == nil {
            inactiveListenerRegistration = db.collection("keys/\(user.lockerId)/inactive")
                .addSnapshotListener { [weak self] (querySnapshot, error) in
                  guard let documents = querySnapshot?.documents else {
                    self?.errorMessage = "No documents in 'inactive' collection"
                    return
                  }
                  
                  self?.inactiveKeys = documents.compactMap { queryDocumentSnapshot in
                    let result = Result { try queryDocumentSnapshot.data(as: LockerKey.self) }
                    
                    switch result {
                    case .success(let key):
                      return key
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
    
    func createKey (key: LockerKey, user: LockerUser) {
        let collectionRef = db.collection("keys/\(user.lockerId)/active")
        do {
          let newDocReference = try collectionRef.addDocument(from: key)
          print("Parcel stored with new document reference: \(newDocReference)")
        }
        catch {
          print(error)
        }
      }
    
    func deleteKey(key: LockerKey, user: LockerUser, type: String) {
        
        if type == "active" {
            db.collection("keys/\(user.lockerId)/active").document(key.id!).delete() { err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("Document successfully removed!")
                }
            }
        } else {
            db.collection("keys/\(user.lockerId)/inactive").document(key.id!).delete() { err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("Document successfully removed!")
                }
            }
        }
        
    }
}
