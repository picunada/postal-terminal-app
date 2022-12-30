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

enum FBAuthError: LocalizedError {
    case reauthenticationNeeded
    case wrongPassword
    case emailAlreadyInUse
    case missingEmail
    case defaultAuthError
    case defaultSignUpError
    
    var errorDescription: String? {
        switch self {
        case .reauthenticationNeeded:
            return "Reauthentication error"
        case .wrongPassword:
            return "Credentials error"
        case .emailAlreadyInUse:
            return "Email already in use"
        case .missingEmail:
            return "Wrong email"
        case .defaultAuthError:
            return "Authentication error"
        case .defaultSignUpError:
            return "Sign up error"
        }
        
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .reauthenticationNeeded:
            return "You need to reauthenticate in order to update your account info"
        case .wrongPassword:
            return "Wrong password"
        case .emailAlreadyInUse:
            return "Change email"
        case .missingEmail:
            return "Check if email is correct"
        case .defaultAuthError:
            return "Check your credentials"
        case .defaultSignUpError:
            return "Check credentials for sign up"
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
    
    private var listenerRegistration: ListenerRegistration?
    
    func fetchUser(userId: String) {
        loading = .loading
        
        self.listenerRegistration = db.collection("users").document(userId)
            .addSnapshotListener {[weak self] (snap, error) in
                guard let document = snap else {
                        print("Error fetching document: \(error!)")
                        return
                      }
                let result = Result { try document.data(as: LockerUser.self) }
                
                switch result {
                case .success(let user):
                    self?.lockerUser = user
                case .failure(let error):
                    self?.error = error
                }
                
                self?.loading = .loaded
            }
    }
    
    func createUser(userId: String, user: LockerUser) {
        let docRef = db.collection("users").document(userId)
        do {
            try docRef.setData(from: user)
        } catch let error {
            print("Error writing city to Firestore: \(error)")
        }
    }
    
    func logout() {
        do { try Auth.auth().signOut() }
        catch { print("already logged out") }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
            self.lockerUser = nil
            self.listenerRegistration?.remove()
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
    
    func updateLocker(lockerId: String) {
        if let user = self.lockerUser {
            let docRef = db.collection("users").document(user.id!)
            
            docRef.updateData([
                "lockerId": lockerId
            ]) { err in
                if let err = err {
                    print("Error updating document: \(err)")
                } else {
                    print("Document successfully updated")
                }
            }
        }
    }
    
    func updatePassword(_ reauthCredential: AuthCredential, credentials: ChangePasswordCredentials) {
        user?.reauthenticate(with: reauthCredential) { i, error   in
          if let error = error {
              print(error)
              self.error = FBAuthError.wrongPassword
          } else {
              guard credentials.password != nil else {
                  self.error = FBAuthError.wrongPassword
                  return
              }
              
              if credentials.password != "" && credentials.password == credentials.confirmPassword {
                  self.user?.updatePassword(to: credentials.password!) { error in
                      if error != nil {
                          self.error = FBAuthError.wrongPassword
                      } else {
                          self.updateSuccess = true
                      }
                  }
              } else {
                  self.error = FBAuthError.wrongPassword
              }
          }
        }
    }
}


