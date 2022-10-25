//
//  ContentView.swift
//  locker-test
//
//  Created by Danil Bezuglov on 10/15/22.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var authState: AuthViewModel
    
    @StateObject var parcelState: ParcelViewModel = ParcelViewModel()
    @StateObject var keysState: KeysViewModel = KeysViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    TabView() {
                        HomeView()
                            .tabItem {
                                Label("Home", systemImage: "house")
                            }
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
                        NotificationsView()
                            .tabItem {
                                Label("Notifications", systemImage: "bell")
                            }
                        ProfileView()
                            .tabItem {
                                Label("Profile", systemImage: "person")
                            }
                    }.accentColor(Color(UIColor.systemIndigo))
                }
                .padding()
            }
        }
        .accentColor(Color(UIColor.systemIndigo))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
