//
//  ContentView.swift
//  locker-test
//
//  Created by Danil Bezuglov on 10/15/22.
//

import SwiftUI
<<<<<<< HEAD
=======
import Inject
import Combine
>>>>>>> github/ios

struct ContentView: View {
    
    @EnvironmentObject var authState: AuthViewModel
<<<<<<< HEAD
=======
    @ObservedObject private var iO = Inject.observer
>>>>>>> github/ios
    
    @StateObject var parcelState: ParcelViewModel = ParcelViewModel()
    @StateObject var keysState: KeysViewModel = KeysViewModel()
    
<<<<<<< HEAD
    init() {
        
        if #available(iOS 15, *) {
            UITabBar.appearance().backgroundColor = UIColor.systemGray6
        }
    }
    
    var body: some View {
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
        }
        .accentColor(Color(UIColor.systemIndigo))
=======
    @State private var cancellables: Set<AnyCancellable> = .init()
    
    @Namespace private var animation
    
    @State var selection: Int = 0
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
//                Capsule()
//                    .frame(width: 30, height: 5)
//                    .foregroundColor(Color("AccentColor"))
//                    .padding(.top, geo.size.height / 5 * 4 + 5)
//                    .padding(.leading, (geo.size.width / 5) * CGFloat(selection) + 24)
//                    .zIndex(10)
//                    .animation(.spring(response: 0.4, dampingFraction: 0.7), value: selection)
                
                TabView(selection: $selection) {
                    HomeView()
                        .environmentObject(keysState)
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
            .enableInjection()
        }
        .ignoresSafeArea()
>>>>>>> github/ios
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
