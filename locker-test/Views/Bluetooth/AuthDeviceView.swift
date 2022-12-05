//
//  AuthDeviceView.swift
//  locker-test
//
//  Created by Danil Bezuglov on 11/24/22.
//

import SwiftUI
import CoreBluetooth

extension Binding {
     func toUnwrapped<T>(defaultValue: T) -> Binding<T> where Value == Optional<T>  {
        Binding<T>(get: { self.wrappedValue ?? defaultValue }, set: { self.wrappedValue = $0 })
    }
}

struct AuthDeviceView: View {
    
    @StateObject var mvm: MainBluetoothViewModel = .init()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(uiColor: .secondarySystemBackground).ignoresSafeArea()
                VStack {
                    content()
                }
                .onAppear {
                    mvm.start()
                }
                .padding()
                .navigationBarTitle("Locker connection")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                                ToolbarItem(placement: .principal) {
                                    // this sets the screen title in the navigation bar, when the screen is visible
                                    Text("Locker connection")
                                        .bold()
                                }
                            }
            }
        }
    }
    
    @ViewBuilder
    private func content() -> some View {
        HStack(alignment: .top) {
            VStack {
                Text("STEP 1")
                    .frame(width: 70, height: 70)
                    .foregroundColor(.white)
                    .background((mvm.peripheral != nil) ?  Color(.systemGreen) : Color(.systemGray))
                    .clipShape(Circle())
                Text("Locker found by Bluetooth")
                    .multilineTextAlignment(.center)
                    .frame(width: 100, height: 75)
            }
            .animation(.default, value: mvm.peripheral != nil)
            Path { path in
                path.move(to: CGPoint(x: -10, y: 35))
                path.addLine(to: CGPoint(x: 100, y: 35))
            }
            .stroke((mvm.peripheral != nil) ? Color(.systemGreen) : .gray , lineWidth: 1)
            .animation(.default, value: mvm.peripheral != nil)
            VStack {
                Text("STEP 2")
                    .frame(width: 70, height: 70)
                    .foregroundColor(.white)
                    .background(Color(.systemGray))
                    .clipShape(Circle())
                Text("Locker connected to the Cloud")
                    .multilineTextAlignment(.center)
                    .frame(width: 100, height: 75)
            }
        }
        .padding(.horizontal, 25)
        .padding(.top, 50)
        .padding(.bottom, -40)
        VStack {
            if let peripheral = mvm.peripheral {
                DeviceWifiView(peripheral: peripheral)
            } else {
                VStack {
                    Text("IMPORTANT: Locker must be turned on and be near your phone on which Bluetooth is activated")
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(10)
                    Image("BluetoothLockerImage")
                        .padding(.vertical, 60)
                }
            }
        }
        .animation(.default, value: mvm.peripheral != nil)
    }
}


struct DeviceWifiView: View {
    
    @StateObject private var viewModel: DeviceViewModel
    @State private var didAppear: Bool = false
    @State var isShowingConnectView: Bool = false

    
    init(peripheral: CBPeripheral) { 
            let viewModel = DeviceViewModel(peripheral: peripheral)
            _viewModel = .init(wrappedValue: viewModel)
        }
    
    var body: some View {
        VStack {
            content()
                .onAppear {
                    guard didAppear == false else {
                        return
                    }
                    viewModel.connect()
                    didAppear = true
                }
        }
    }
    
    @ViewBuilder
        private func content() -> some View {
            VStack {
                if let wifiNetworks = viewModel.networks {
                    VStack {
                        Text("IMPORTANT: Locker must be within Wi-Fi coverage")
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(10)
                        List {
                            ForEach(wifiNetworks.networks, id: \.self) { network in
                                HStack {
                                    Text(network.SSID)
                                    Spacer()
                                    if network.isOpen == 0 {
                                        Image(systemName: "lock.fill")
                                    }
                                    Image(systemName: "wifi")
                                }
                                .onTapGesture {
                                    isShowingConnectView.toggle()
                                }
                                .sheet(isPresented: $isShowingConnectView) {
                                    ConnectWifiView($isShowingConnectView, network: network, vm: viewModel)
                                }
                            }
                        }
                    }
                } else {
                    VStack {
                        LoadingView()
                    }
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    viewModel.write(BLEData(command: "get").toData()!)
                }
            }
        }
}

struct ConnectWifiView: View {
    @Binding var isShowing: Bool
    @ObservedObject var vm: DeviceViewModel
    var network: WifiNetwork
    
    @State var data: BLEData = .init(command: "set", password: "", fb_login: "xlayst@example.com", fb_password: "104931")
    
    
    init(_ show: Binding<Bool>, network: WifiNetwork, vm: DeviceViewModel) {
        self._isShowing = show
        self.network = network
        self.vm = vm
    }
    
    
    var body: some View {
        NavigationView {
            VStack {
                TextInputField("Password", text: $data.password.toUnwrapped(defaultValue: ""))
                Button {
                    if data.password != nil {
                        vm.write(data.toData()!)
                    }
                    
                } label: {
                    Text("Connect")
                        .bold()
                        .foregroundColor(.white)
                }
                .padding()
                .background(Color(UIColor.secondaryLabel).cornerRadius(8))
                .accessibilityLabel("Connect wi-fi")

            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(network.SSID)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                                    Button {
                                        isShowing.toggle()
                                    } label: {
                                        Image(systemName: "multiply")
                                            .foregroundColor(.black)
                                    }
                                }
                            }
        }
    }
}

struct AuthDeviceView_Previews: PreviewProvider {
    static var previews: some View {
        AuthDeviceView()
    }
}
