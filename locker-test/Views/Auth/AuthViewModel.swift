//
//  AuthViewModel.swift
//  locker-test
//
//  Created by Danil Bezuglov on 10/15/22.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

struct LockerUser: Identifiable, Codable {
    @DocumentID var id: String?
    var firstName: String
    var lastName: String
    var lockerId: String
    
    var dictionary: [String: Any] {
            let data = (try? JSONEncoder().encode(self)) ?? Data()
            return (try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]) ?? [:]
        }
}

class AuthViewModel: ObservableObject {
    
    enum State {
            case idle
            case loading
            case failed
            case loaded
        }
    
    static let shared = AuthViewModel()
    
    let db = Firestore.firestore()
    
    enum SignInState {
        case signedIn
        case signedOut
    }
    
    @Published private(set) var loading = State.idle
    @Published var lockerUser: LockerUser?
    @Published var errorMessage: String?
    
    @Published var state: SignInState = .signedOut {
        didSet {
            if state != .signedOut {
                self.fetchUser(userId: Auth.auth().currentUser!.uid)
            } else {
                self.lockerUser = nil
            }
        }
    }
    
    init() {
        
    }
    
    private func fetchUser(userId: String) {
        loading = .loading
        
        let docRef = db.collection("users").document(userId)
        
        docRef.getDocument(as: LockerUser.self) { result in
            switch result {
            case .success(let user):
                // A `City` value was successfully initialized from the DocumentSnapshot.
                print("User: \(user)")
                self.lockerUser = user
                self.loading = .loaded
            case .failure(let error):
                // A `City` value could not be initialized from the DocumentSnapshot.
                print("Error decoding city: \(error)")
                self.loading = .failed
            }
        }
    }
    
    func createUser(user: LockerUser) {
        if let id = user.id {
            let docRef = db.collection("users").document(id)
            do {
                try docRef.setData(from: user)
            } catch let error {
                print("Error writing city to Firestore: \(error)")
            }
          }
    }
    
    func logout() {
        do { try Auth.auth().signOut() }
        catch { print("already logged out") }
    }
}


