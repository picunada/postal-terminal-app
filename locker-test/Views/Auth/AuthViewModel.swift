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
    var lockerId: String?
    
    var dictionary: [String: Any] {
            let data = (try? JSONEncoder().encode(self)) ?? Data()
            return (try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]) ?? [:]
        }
}

struct FirebaseCredentials: Codable {
    var email: String?
    var password: String?
}

struct ChangePasswordCredentials: Codable {
    var password: String?
    var confirmPassword: String?
}

enum AuthError: LocalizedError {
    case reauthenticationNeeded
    case wrongPassword
    
    
    var errorDescription: String? {
        switch self {
        case .reauthenticationNeeded:
            return "Reauthentication error"
        case .wrongPassword:
            return "Credentials error"
        }
        
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .reauthenticationNeeded:
            return "You need to reauthenticate in order to update your account info"
        case .wrongPassword:
            return "Wrong password"
        }
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
    @Published var user: User?
    @Published var error: Swift.Error?
    
    @Published var state: SignInState = .signedOut {
        didSet {
            if state != .signedOut {
                self.fetchUser(userId: Auth.auth().currentUser!.uid)
                self.user = Auth.auth().currentUser
            }
        }
    }
    
    @Published var updateSuccess: Bool = false
    
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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
            self.lockerUser = nil
        })
    }
    
    func updateEmail(email: String) {        
        Auth.auth().currentUser?.updateEmail(to: email) { error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    func updateUserInfo(lockerUser: LockerUser) {
        let docRef = db.collection("users").document(lockerUser.id!)
        
        docRef.updateData([
            "firstName": lockerUser.firstName,
            "lastName": lockerUser.lastName
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }
    }
    
    func updatePassword(_ reauthCredential: AuthCredential, credentials: ChangePasswordCredentials) {
        user?.reauthenticate(with: reauthCredential) { i, error   in
          if let error = error {
              print(error)
              self.error = AuthError.wrongPassword
          } else {
              guard credentials.password != nil else {
                  self.error = AuthError.wrongPassword
                  return
              }
              
              if credentials.password != "" && credentials.password == credentials.confirmPassword {
                  self.user?.updatePassword(to: credentials.password!) { error in
                      if error != nil {
                          self.error = AuthError.wrongPassword
                      } else {
                          self.updateSuccess = true
                      }
                  }
              } else {
                  self.error = AuthError.wrongPassword
              }
          }
        }
    }
}


