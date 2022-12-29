//
//  HomeView.swift
//  locker-test
//
//  Created by Danil Bezuglov on 10/15/22.
//

import SwiftUI
import CoreBluetooth
import Combine

struct HomeView: View {
    
    @StateObject private var vm: MainViewModel = .init()
    @StateObject private var telemetryVM: TelemetryViewModel = .init()
    @EnvironmentObject var authState: AuthViewModel
    @State private var devicesViewIsPresented = false
    @State var cancellables: Set<AnyCancellable> = .init()
    
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
            .accentColor(.primary)
            .onAppear {
                vm.start()

                
                authState.$lockerUser
                    .filter({ user in
                        return user != nil
                    })
                    .sink { user in
                        telemetryVM.subscribe(user: user!)
                    }
                    .store(in: &cancellables)
            }
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
