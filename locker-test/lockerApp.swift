//
//  locker_testApp.swift
//  locker-test
//
//  Created by Danil Bezuglov on 10/15/22.
//

import SwiftUI
import Firebase
import FirebaseMessaging
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate {
    let gcmMessageIDKey = "gcm.message_id"
    
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
      
      

         func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
             FirebaseApp.configure()

             Messaging.messaging().delegate = self

             if #available(iOS 10.0, *) {
               // For iOS 10 display notification (sent via APNS)
               UNUserNotificationCenter.current().delegate = self

               let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
               UNUserNotificationCenter.current().requestAuthorization(
                 options: authOptions,
                 completionHandler: {_, _ in })
             } else {
               let settings: UIUserNotificationSettings =
               UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
               application.registerUserNotificationSettings(settings)
             }

             application.registerForRemoteNotifications()
             return true
         }

         func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                          fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {

           if let messageID = userInfo[gcmMessageIDKey] {
             print("Message ID: \(messageID)")
           }

           print(userInfo)

           completionHandler(UIBackgroundFetchResult.newData)
         }

    return true
  }
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {

      let deviceToken:[String: String] = ["token": fcmToken ?? ""]
        print("Device token: ", deviceToken) // This token can be used for testing notifications on FCM
    }
}

@available(iOS 10, *)
extension AppDelegate: UNUserNotificationCenterDelegate {

  // Receive displayed notifications for iOS 10 devices.
  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    let userInfo = notification.request.content.userInfo

    if let messageID = userInfo[gcmMessageIDKey] {
        print("Message ID: \(messageID)")
    }

    print(userInfo)

    // Change this to your preferred presentation option
    completionHandler([[.banner, .badge, .sound]])
  }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {

    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {

    }

  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              didReceive response: UNNotificationResponse,
                              withCompletionHandler completionHandler: @escaping () -> Void) {
    let userInfo = response.notification.request.content.userInfo

    if let messageID = userInfo[gcmMessageIDKey] {
      print("Message ID from userNotificationCenter didReceive: \(messageID)")
    }

    print(userInfo)

    completionHandler()
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
