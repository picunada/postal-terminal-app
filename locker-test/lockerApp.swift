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
      
      UINavigationBar.appearance().backIndicatorImage = UIImage(systemName: "arrow.left")
      UINavigationBar.appearance().backIndicatorTransitionMaskImage = UIImage(systemName: "arrow.left")
      UINavigationBar.appearance().tintColor = .black

    return true
  }
}

public extension CGFloat {
    /**
     Converts pixels to points based on the screen scale. For example, if you
     call CGFloat(1).pixelsToPoints() on an @2x device, this method will return
     0.5.
     
     - parameter pixels: to be converted into points
     
     - returns: a points representation of the pixels
     */
    func pixelsToPoints() -> CGFloat {
        return self / UIScreen.main.scale
    }
    
    /**
     Returns the number of points needed to make a 1 pixel line, based on the
     scale of the device's screen.
     
     - returns: the number of points needed to make a 1 pixel line
     */
    static func onePixelInPoints() -> CGFloat {
        return CGFloat(1).pixelsToPoints()
    }
}

extension View {
    func disableScrolling(disabled: Bool) -> some View {
        modifier(DisableScrolling(disabled: disabled))
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
                if authState.state == .signedIn {
                    ContentView()
                        .environmentObject(authState)
                } else {
                    AuthView()
                        .environmentObject(authState)
                }
            case .idle:
                if authState.state == .signedIn {
                    ContentView()
                        .environmentObject(authState)
                } else {
                    AuthView()
                        .environmentObject(authState)
                }
            case .failed:
                if authState.state == .signedIn {
                    ContentView()
                        .environmentObject(authState)
                } else {
                    AuthView()
                        .environmentObject(authState)
                }
            }
        }
    }
}
