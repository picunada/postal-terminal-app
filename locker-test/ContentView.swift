//
//  ContentView.swift
//  locker-test
//
//  Created by Danil Bezuglov on 10/15/22.
//

import SwiftUI
import Inject

struct ContentView: View {
    
    @EnvironmentObject var authState: AuthViewModel
    @ObservedObject private var iO = Inject.observer
    
    @StateObject var parcelState: ParcelViewModel = ParcelViewModel()
    @StateObject var keysState: KeysViewModel = KeysViewModel()
    
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
                        .tabItem {
                            Label("Home", systemImage: "house")
                        }
                        .tag(0)
                        .background(TabBarAccessor { tabBar in
                            tabBar.items?[1].isEnabled = authState.lockerUser?.lockerId != ""
                            tabBar.items?[2].isEnabled = authState.lockerUser?.lockerId != ""
                            tabBar.items?[3].isEnabled = authState.lockerUser?.lockerId != ""
                        })
                    
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
                        .tabItem {
                            Label("Notifications", systemImage: "bell")
                        }
                        .tag(3)
                        
                    
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
    }
}

struct TabBarAccessor: UIViewControllerRepresentable {
    var callback: (UITabBar) -> Void
    private let proxyController = ViewController()

    func makeUIViewController(context: UIViewControllerRepresentableContext<TabBarAccessor>) ->
                              UIViewController {
        proxyController.callback = callback
        return proxyController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<TabBarAccessor>) {
    }
    
    typealias UIViewControllerType = UIViewController

    private class ViewController: UIViewController {
        var callback: (UITabBar) -> Void = { _ in }

        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            if let tabBar = self.tabBarController {
                self.callback(tabBar.tabBar)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
