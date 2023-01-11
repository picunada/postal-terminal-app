//
//  ContentView.swift
//  locker-test
//
//  Created by Danil Bezuglov on 10/15/22.
//

import SwiftUI
import Inject
import Combine

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
                }
                .tag(0)
            
            if  (authState.lockerUser?.lockerId ?? "").isEmpty {
                ParcelsNotAvailableView()
                    .tabItem {
                        Label("Parcels", systemImage: "shippingbox")
                    }
                    .accentColor(.gray)
                    .tag(1)
                
                KeysNotAvailableView()
                    .tabItem {
                        Label("Keys", systemImage: "lock.rotation")
                    }
                    .accentColor(.gray)
                    .tag(2)
                NotificationsNotAvailableView()
                    .tabItem {
                        Label("Notifications", systemImage: "bell")
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
                    }
                    .tag(2)
                NotificationsView()
                    .environmentObject(notificationsManager)
                    .disabled(true)
                    .tabItem {
                        Label("Notifications", systemImage: "bell")
                    }
                    .tag(3)
            }
           
                
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
                .tag(4)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
