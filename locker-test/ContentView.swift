//
//  ContentView.swift
//  locker-test
//
//  Created by Danil Bezuglov on 10/15/22.
//

import SwiftUI
import Inject
import Combine
import FirebaseFirestore

struct ContentView: View {
    
    @EnvironmentObject var authState: AuthViewModel
    @ObservedObject private var iO = Inject.observer
    
    @StateObject var parcelState: ParcelViewModel = ParcelViewModel()
    @StateObject var keysState: KeysViewModel = KeysViewModel()
    @StateObject var notificationsManager: NotificationsManager = NotificationsManager()
    
    @State private var cancellables: Set<AnyCancellable> = .init()
    
    @Namespace private var animation
    
    @State var selection: Int = 0
    
    var body: some View {
        TabView(selection: $selection) {
            HomeView()
                .environmentObject(keysState)
                .environmentObject(notificationsManager)
                .tabItem {
                    Label("Home", systemImage: "house")
                        .environment(\.symbolVariants, .none)
                }
                .tag(0)
            
            if  (authState.lockerUser?.lockerId ?? "").isEmpty {
                ParcelsNotAvailableView()
                    .tabItem {
                        Label("Parcels", systemImage: "shippingbox")
                            .environment(\.symbolVariants, .none)
                    }
                    .accentColor(.gray)
                    .tag(1)
                
                KeysNotAvailableView()
                    .tabItem {
                        Label("Keys", systemImage: "lock.rotation")
                            .environment(\.symbolVariants, .none)
                    }
                    .accentColor(.gray)
                    .tag(2)
                NotificationsNotAvailableView()
                    .tabItem {
                        Label("Notifications", systemImage: "bell")
                            .environment(\.symbolVariants, .none)
                    }
                    .accentColor(.gray)
                    .tag(3)
            } else {
                ParcelsView(parcelState: parcelState)
                    .onAppear {
                        parcelState.subscribe(user: authState.lockerUser!)
                    }
                    .onDisappear {
                        parcelState.unsubscribe()
                    }
                    .tabItem {
                        Label("Parcels", systemImage: "shippingbox")
                            .environment(\.symbolVariants, .none)
                    }
                    .tag(1)
                
                KeysView(keyState: keysState)
                    .onAppear {
                        keysState.subscribe(user: authState.lockerUser!)
                    }
                    .onDisappear {
                        keysState.unsubscribe()
                    }
                    .tabItem {
                        Label("Keys", systemImage: "lock.rotation")
                            .environment(\.symbolVariants, .none)
                    }
                    .tag(2)
                NotificationsView()
                    .environmentObject(notificationsManager)
                    .disabled(true)
                    .tabItem {
                        Label("Notifications", systemImage: "bell")
                            .environment(\.symbolVariants, .none)
                    }
                    .tag(3)
            }
           
                
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person")
                        .environment(\.symbolVariants, .none)
                }
                .tag(4)
        }
        .onAppear {
            authState.$lockerUser
                .compactMap { $0 }
                .sink { user in
                    print("=================================================")
                    print("received")
                    print(user)
                    guard let tokenDict = authState.fcmToken else {
                        print("net tokena")
                        return
                    }
                    if let lockerId = user.lockerId {
                        guard !lockerId.isEmpty else {
                            print("Not send. LockerId: \(lockerId)")
                            return
                        }
                        let db = Firestore.firestore()
                        db.collection("mobile_tokens").document(lockerId).setData(tokenDict)
                        print("Send to lockerID: \(lockerId)")
                    }
                }
                .store(in: &cancellables)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
