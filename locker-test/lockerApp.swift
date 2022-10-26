//
//  locker_testApp.swift
//  locker-test
//
//  Created by Danil Bezuglov on 10/15/22.
//

import SwiftUI
import Firebase

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
      
    Auth.auth().addStateDidChangeListener { auth, user in
        if user != nil {
            AuthViewModel.shared.state = .signedIn
        } else {
            AuthViewModel.shared.state = .signedOut
        }
    }

    return true
  }
}

@main
struct lockerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @StateObject var authState: AuthViewModel = AuthViewModel.shared
    
    var body: some Scene {
        WindowGroup {
            switch authState.loading {
            case .loading :
                LoadingView()
                .transition(.slide)
            case .loaded:
                if authState.lockerUser != nil {
                    ContentView()
                        .environmentObject(authState)
                } else {
                    AuthView()
                        .environmentObject(authState)
                }
            case .idle:
                LoadingView()
                .transition(.slide)
            case .failed:
                LoadingView()
                .transition(.slide)
            }
        }
    }
}
