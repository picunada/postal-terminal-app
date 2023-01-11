//
//  HomeView.swift
//  locker-test
//
//  Created by Danil Bezuglov on 10/15/22.
//

import SwiftUI
import CoreBluetooth
import Combine

//struct NotificationTest: Identifiable, Codable, Hashable {
//    var id: UUID = UUID()
//    var title: String
//    var description: String
//}

struct HomeView: View {
    
    @StateObject private var vm: MainViewModel = .init()
    @StateObject private var telemetryVM: TelemetryViewModel = .init()
    @EnvironmentObject var authState: AuthViewModel
    @EnvironmentObject var notificationsManager: NotificationsManager
    @State private var devicesViewIsPresented = false
    @State var cancellables: Set<AnyCancellable> = .init()
    
//    @State var testNotifications: [NotificationTest] = [NotificationTest(title: "Parcel from DHL", description: "Test"), NotificationTest(title: "Parcel from EMS", description: "Test"), NotificationTest(title: "Parcel from FedEx", description: "Test")]
    
    var body: some View {
        ZStack {
            Color(uiColor: .secondarySystemBackground).ignoresSafeArea()
            NavigationView {
                VStack {
                    content()
                }
                .padding(.bottom, 40)
                .padding(.top, 55)
                .navigationBarTitle("")
                .navigationBarHidden(true)

            }
            .onAppear {
                vm.start()
                
                notificationsManager.reloadAuthorizationStatus()
                
                authState.$lockerUser
                    .filter({ user in
                        return user != nil
                    })
                    .sink { user in
                        telemetryVM.subscribe(user: user!)
                    }
                    .store(in: &cancellables)
            }
            .onChange(of: notificationsManager.authorizationStatus, perform: { authorizationStatus in
                switch authorizationStatus {
                case .notDetermined:
                    notificationsManager.requestAuthorization()
                case .authorized:
                    notificationsManager.reloadLocalNotifications()
                default:
                    break
                }
            })
        }
        
    }
    
    //MARK: - Private
    
    @ViewBuilder
    private func content() -> some View {
        VStack(alignment: .center) {
            if (authState.lockerUser?.lockerId ?? "").isEmpty {
                HStack(alignment: .center) {
                    Text("")
                        .bold()
                        .foregroundColor(Color(.systemGray))
                    Spacer()
                    HStack {
                        Image(systemName: "antenna.radiowaves.left.and.right.slash")
                            .foregroundColor(Color(.systemGray))
                        Text("Offline")
                            .font(.subheadline)
                            .bold()
                            .foregroundColor(Color(.systemGray))
                    }
                    HStack {
                        Image(systemName: "battery.0")
                            .foregroundColor(Color(.systemGray))
                        Text("N/A")
                            .font(.subheadline)
                            .bold()
                            .foregroundColor(Color(.systemGray))
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 45)
                Image("Home Screen")
                    .frame(width: 257, height: 271)
                
                Spacer()
                
                NavigationLink {
                    AuthDeviceView()
                        .navigationTitle("Locker connection")
                        .navigationBarTitleDisplayMode(.inline)
                } label: {
                    Text("Add locker")
                        .font(.title3)
                        .bold()
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.white)
                        .padding()
                }
                .frame(height: 48)
                .background(Color("AccentColor"))
                .cornerRadius(8)
                .padding(.horizontal)
            } else {
                HStack(alignment: .center) {
                    Text(telemetryVM.telemetry?.name?.capitalized ?? "")
                        .bold()
                        .foregroundColor(Color(.systemGray))
                    Spacer()
                    HStack {
                        Image(systemName: "antenna.radiowaves.left.and.right")
                            .foregroundColor(Color(.systemGray))
                        Text("Online")
                            .font(.subheadline)
                            .bold()
                            .foregroundColor(Color(.systemGray))
                    }
                    HStack {
                        Image(systemName: "battery.\(String(describing: Int(telemetryVM.telemetry?.battery ?? "0")!.rounding(nearest: 25)))")
                            .foregroundColor(Color(.systemGray))
                        Text("\(telemetryVM.telemetry?.battery  ?? "N/A")%")
                            .font(.subheadline)
                            .bold()
                            .foregroundColor(Color(.systemGray))
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 45)
                Image("Home Screen")
                    .frame(width: 257, height: 271)
                
                if !notificationsManager.notifications.isEmpty {
                        ZStack {
                            ForEach(notificationsManager.notifications.indices, id: \.self) { index in
                                HStack {
                                    VStack {
                                        Image(systemName: "shippingbox")
                                            .resizable()
                                            .frame(width: 25, height: 25)
                                            .padding()
                                            .foregroundColor(Color("AccentColor"))
                                    }
                                    .frame(width: 44, height: 44)
                                    VStack(alignment: .leading) {
                                        HStack {
                                            Text(notificationsManager.notifications[index].content.title)
                                                .font(.custom("test", size: 17))
                                                .bold()
                                            Spacer()
                                            Button {
                                                print("current \(index)")
                                                print("last \(notificationsManager.notifications.endIndex)")
                                                withAnimation(.spring()) {
                                                    DispatchQueue.main.async {
                                                        notificationsManager.deleteNotification(index)
                                                    }
                                                }
                                            } label: {
                                                Image(systemName: "multiply")
                                                    .resizable()
                                                    .frame(width: 12, height: 12)
                                                    .foregroundColor(.black)
                                            }
                                        }
                                        .padding(.trailing, 3)
                                        Text(notificationsManager.notifications[index].content.body)
                                            .font(.custom("test1", size: 15))
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.trailing, 7)
                                }
                                .padding(.vertical, 9)
                                .padding(.horizontal, 13)
                                .background(index < notificationsManager.notifications.endIndex - 1 ? Color(UIColor.systemGray5) : Color(UIColor.systemGray6))
                                .cornerRadius(16)
                                .scaleEffect(index < notificationsManager.notifications.endIndex - 1 ? 0.9 : 1.0)
                                .offset(index < notificationsManager.notifications.endIndex - 1 ? CGSize(width: 0, height: 8) : CGSize(width: 0, height: 0))
                            }
                            
                        }
                        .padding(.horizontal)
                        .padding(.top, 45)
                        
                }
                
                
                Spacer()
                
                NavigationLink {
                    MainKeyView()
                        .navigationTitle("Owner's key")
                        .navigationBarTitleDisplayMode(.inline)
                } label: {
                    Text("Open locker")
                        .font(.title3)
                        .bold()
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.white)
                        .padding()
                }
                .frame(height: 48)
                .background(Color("AccentColor"))
                .cornerRadius(8)
                .padding(.horizontal)
            }
        }
    }
    
    private func add() {
        devicesViewIsPresented = true
    }
}

extension Int{
   func rounding(nearest:Float) -> Int{
       return Int(nearest * round(Float(self)/nearest))
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
