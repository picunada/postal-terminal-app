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
      
    Auth.auth().addStateDidChangeListener { (auth, user) in
        if user != nil {
            AuthViewModel.shared.state = .signedIn
        } else {
            AuthViewModel.shared.state = .signedOut
        }
    }
      
      UINavigationBar.appearance().backIndicatorImage = UIImage(systemName: "arrow.left")
      UINavigationBar.appearance().backIndicatorTransitionMaskImage = UIImage(systemName: "arrow.left")
      UINavigationBar.appearance().tintColor = .black

    return true
  }
}

extension UINavigationController {
    // Remove back button text
    open override func viewWillLayoutSubviews() {
        navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
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
                    .animation(.default, value: authState.loading == .loading)
            case .loaded:
                if authState.state != .signedIn {
                    AuthView()
                        .environmentObject(authState)
                } else {
                    ContentView()
                        .withErrorHandling()
                        .environmentObject(authState)
                }
            case .idle:
                if authState.state != .signedIn {
                    AuthView()
                        .environmentObject(authState)
                } else {
                    ContentView()
                        .environmentObject(authState)
                }
            case .failed:
                if authState.state != .signedIn {
                    AuthView()
                        .environmentObject(authState)
                } else {
                    ContentView()
                        .environmentObject(authState)
                }
            }
        }
    }
}
