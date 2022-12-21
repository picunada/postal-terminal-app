//
//  HomeView.swift
//  locker-test
//
//  Created by Danil Bezuglov on 10/15/22.
//

import SwiftUI
import CoreBluetooth

struct HomeView: View {
    
    @StateObject private var vm: MainViewModel = .init()
    @State private var devicesViewIsPresented = false
    
    var body: some View {
        ZStack {
            Color(uiColor: .secondarySystemBackground).ignoresSafeArea()
            NavigationView {
                VStack {
                    content()
                }
                .padding(.bottom, 40)
                .navigationBarTitle("")
                .navigationBarHidden(true)

            }
            .accentColor(.primary)
            .onAppear {
                vm.start()
            }
        }
        
    }
    
    //MARK: - Private
    
    @ViewBuilder
    private func content() -> some View {
        VStack(alignment: .center) {
            HStack(alignment: .center) {
                Text("Duong 2D")
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
        }
    }
    
    private func add() {
        devicesViewIsPresented = true
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
