//
//  KeysViewModel.swift
//  locker-test
//
//  Created by Danil Bezuglov on 10/17/22.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift
<<<<<<< HEAD
=======
import CryptoKit
>>>>>>> github/ios

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

<<<<<<< HEAD
class KeysViewModel: ObservableObject {
    @Published var activeKeys: [LockerKey] = [LockerKey]()
    @Published var inactiveKeys: [LockerKey] = [LockerKey]()
=======
struct MainKey: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var mainKey: String?
}

class KeysViewModel: ObservableObject {
    @Published var activeKeys: [LockerKey] = [LockerKey]()
    @Published var inactiveKeys: [LockerKey] = [LockerKey]()
    @Published var mainKey: MainKey?
>>>>>>> github/ios
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
<<<<<<< HEAD
            activeListenerRegistration = db.collection("keys/\(user.lockerId)/active")
=======
            activeListenerRegistration = db.collection("keys/\(user.lockerId!)/active")
>>>>>>> github/ios
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
<<<<<<< HEAD
            inactiveListenerRegistration = db.collection("keys/\(user.lockerId)/inactive")
=======
            inactiveListenerRegistration = db.collection("keys/\(user.lockerId!)/inactive")
>>>>>>> github/ios
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
    
<<<<<<< HEAD
    func createKey (key: LockerKey, user: LockerUser) {
        let collectionRef = db.collection("keys/\(user.lockerId)/active")
=======
    func createKey(key: LockerKey, user: LockerUser) {
        let collectionRef = db.collection("keys/\(user.lockerId!)/active")
>>>>>>> github/ios
        do {
          let newDocReference = try collectionRef.addDocument(from: key)
          print("Parcel stored with new document reference: \(newDocReference)")
        }
        catch {
          print(error)
        }
      }
    
<<<<<<< HEAD
    func deleteKey(key: LockerKey, user: LockerUser, type: String) {
        
        if type == "active" {
            db.collection("keys/\(user.lockerId)/active").document(key.id!).delete() { err in
=======
    func createMainKey(serial: String) {
        guard !serial.isEmpty else { return }
        
        let inputData = Data(serial.utf8)
        let hashed = SHA256.hash(data: inputData)
        let hashString = hashed.compactMap { String(format: "%02x", $0) }.joined()
        
        let docRef = db.collection("keys").document("\(serial)")
        
        docRef.setData(["mainKey": hashString])
        
        print("main key creation")
      }
    
    func fetchMainKey(user: LockerUser) {
        guard let id = user.lockerId else { return }
        guard !id.isEmpty else { return }
        
        let docRef = db.collection("keys").document(id)

        docRef.getDocument(as: MainKey.self) { result in
            switch result {
            case .success(let key):
                self.mainKey = key
                print("fetched key")
            case .failure(let error):
                print("Error decoding key: \(error)")
            }
        }
    }
    
    func deleteKey(key: LockerKey, user: LockerUser, type: String) {
        
        print(key.id!)
        print(type)
        
        if type == "active" {
            db.collection("keys/\(user.lockerId!)/active").document(key.id!).delete() { err in
>>>>>>> github/ios
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("Document successfully removed!")
                }
            }
        } else {
<<<<<<< HEAD
            db.collection("keys/\(user.lockerId)/inactive").document(key.id!).delete() { err in
=======
            db.collection("keys/\(user.lockerId!)/inactive").document(key.id!).delete() { err in
>>>>>>> github/ios
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("Document successfully removed!")
                }
            }
        }
        
    }
<<<<<<< HEAD
=======
    
    func delete(at offsets: IndexSet, lockerId: String) {
      offsets.map { inactiveKeys[$0] }.forEach { key in
          guard let keyId = key.id else { return }
          db.collection("keys/\(lockerId)/inactive").document(keyId).delete() { err in
          if let err = err {
            print("Error removing document: \(err)")
          } else {
            print("Document successfully removed!")
          }
        }
      }
    }
>>>>>>> github/ios
}
