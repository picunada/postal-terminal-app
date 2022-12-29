//
//  AuthDeviceView.swift
//  locker-test
//
//  Created by Danil Bezuglov on 11/24/22.
//

import SwiftUI
import CoreBluetooth
import Combine

extension Binding {
     func toUnwrapped<T>(defaultValue: T) -> Binding<T> where Value == Optional<T>  {
        Binding<T>(get: { self.wrappedValue ?? defaultValue }, set: { self.wrappedValue = $0 })
    }
}

struct AuthDeviceView: View {
    
    @StateObject var mvm: MainBluetoothViewModel = .init()
    
    var body: some View {
        ZStack {
            Color(uiColor: .secondarySystemBackground).ignoresSafeArea()
            ScrollView {
                HStack(alignment: .top, spacing: 0) {
                    VStack(alignment: .center, spacing: 0) {
                        content()
                            .padding(.all, 0)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 40)
                .onAppear {
                    mvm.start()
                }
            }
        }
    }
    
    @ViewBuilder
    private func content() -> some View {
        VStack(spacing: 45) {
            HStack {
                VStack(spacing: 10) {
                    if mvm.peripheral != nil {
                        VStack {
                            Image(systemName: "checkmark")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.white)
                        }
                        .frame(width: 55, height: 55)
                        .background(Color(.systemGreen))
                        .clipShape(Circle())
                    } else {
                        VStack {
                            Text("STEP 1")
                                .font(.caption)
                                .foregroundColor(.white)
                        }
                        .frame(width: 55, height: 55)
                        .background(Color(.systemGreen))
                        .clipShape(Circle())
                    }
                    
                    
                    VStack {
                        Text("Locker found by \n Bluetooth")
                            .multilineTextAlignment(.center)
                            .font(.custom("BLE", fixedSize: 16))
                            .lineSpacing(5)
                    }
                    .frame(height: 42)
                }
                .frame(width: 139)
                .animation(.default, value: mvm.peripheral != nil)
                
                Spacer()
                
                Path { path in
                    path.move(to: CGPoint(x: -66, y: 27.5))
                    path.addLine(to: CGPoint(x: 66, y: 27.5))
                }
                .stroke((mvm.peripheral != nil) ? Color(.systemGreen) : .gray , lineWidth: 1)
                .frame(width: 1)
                .animation(.default, value: mvm.peripheral != nil)
                
                Spacer()

                VStack(spacing: 10) {
                    if mvm.connectionState == .connected {
                        VStack {
                            Image(systemName: "checkmark")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.white)
                        }
                        .frame(width: 55, height: 55)
                        .background(Color(.systemGreen))
                        .clipShape(Circle())
                    } else {
                        VStack {
                            Text("STEP 2")
                                .font(.caption)
                                .foregroundColor(.white)
                        }
                        .frame(width: 55, height: 55)
                        .background((mvm.peripheral != nil) ?  Color(.systemGreen) : Color(.systemGray))
                        .clipShape(Circle())
                    }
                    
                    
                    VStack {
                        Text("Locker connected \n to the Cloud")
                            .multilineTextAlignment(.center)
                            .font(.custom("BLE", fixedSize: 16))
                            .lineSpacing(5)
                    }
                    .frame(height: 42)
                    .frame(maxWidth: .infinity)
                }
                .frame(width: 139)
            }
            .frame(height: 105)
            
            if mvm.connectionState == .connected {
                
                Image("Home Screen")
                    .frame(width: 256, height: 270)
                
                Text("Your locker is connected and ready to receive packages!")
                    .font(.custom("Connected", size: 20))
                    .bold()
                    .multilineTextAlignment(.center)
                    .padding(.top, 60)
                
            } else if let peripheral = mvm.peripheral {
                DeviceWifiView(peripheral: peripheral, vm: mvm)
            } else {
                VStack {
                    
                        VStack(spacing: 45) {
                            Text("IMPORTANT: Locker must be turned on and be near your phone on which Bluetooth is activated")
                                .padding()
                                .frame(width: 343, height: 104)
                                .background(Color(.systemBackground))
                                .cornerRadius(10)
                                
                            ZStack {
                                
                                Image("BluetoothLockerImage")
                                GIFView(type: .name("bright_bth"))
                                    .frame(width: 160, height: 160)
                                    .zIndex(1)
                                    .padding(.bottom, 45)
                            }
                            .frame(width: 215, height: 242)
                        }
                }
                .animation(.default, value: mvm.peripheral != nil)
            }
        }
    }
}


struct DeviceWifiView: View {
    
    @StateObject private var viewModel: DeviceViewModel
    @ObservedObject var mvm: MainBluetoothViewModel
    @State private var didAppear: Bool = false

    @State var wifiNetwork: WifiNetwork?
    
    @State private var cancellables: Set<AnyCancellable> = .init()

    
    init(peripheral: CBPeripheral, vm: MainBluetoothViewModel) {
            let viewModel = DeviceViewModel(peripheral: peripheral)
            self.mvm = vm
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
                    viewModel.$connectionState
                        .sink { state in
                            mvm.connectionState = state
                        }
                        .store(in: &cancellables)
                }
        }
    }
    
    @ViewBuilder
        private func content() -> some View {
            VStack(spacing: 0) {
                VStack(spacing: 0) {
                    Text("IMPORTANT: Locker must be within Wi-Fi coverage")
                        .padding()
                        .frame(width: 343, height: 104)
                        .background(Color(.systemBackground))
                        .cornerRadius(10)
                    
                    HStack {
                        Text("AVAILABLE WI-FI NETWORKS")
                            
                        
                        if viewModel.networks == nil {
                            Image(systemName: "rays")
                                .resizable()
                                .frame(width: 28, height: 28)
                                .rotationEffect(Angle(degrees: 360))
                                .animation(Animation.linear(duration: 3).repeatForever(autoreverses: false), value: viewModel.loadingState)
                                .onAppear() {
                                    viewModel.loadingState = .loading
                                            }
                        }
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 45)
                    .padding(.bottom, 15)
                
                if let wifiNetworks = viewModel.networks {
                    VStack {
                        ForEach(wifiNetworks.networks, id: \.id) { network in
                            VStack {
                                Button(action: {
                                    wifiNetwork = network
                                }, label: {
                                    HStack {
                                        Text(network.SSID)
                                        Spacer()
                                        if network.isOpen == 0 {
                                            Image(systemName: "lock.fill")
                                        }
                                        Image(systemName: "wifi")
                                    }
                                    .frame(height: 30)
                                    .padding(.horizontal)
                                })
                            }
                            .padding(.vertical)
                            .listRowInsets(EdgeInsets())
                        }
                    }
                    .padding()
                    .background(Color.primary.colorInvert())
                    .cornerRadius(15)
                        
                    
                    } else {
                        ProgressView()
                            .font(.largeTitle)
                    }
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    viewModel.write(BLEData(command: "get").toData()!)
                }
            }
            .sheet(item: self.$wifiNetwork) {
                ConnectWifiView(network: $0, vm: viewModel)
            }
        }
}

struct ConnectWifiView: View {
    
    @StateObject var keysVM: KeysViewModel = .init()
    
    @ObservedObject var vm: DeviceViewModel
    @EnvironmentObject var authState: AuthViewModel
    @EnvironmentObject var errorHandling: ErrorHandling
    @Environment(\.presentationMode) var presentationMode
    var network: WifiNetwork
    
    @State var cancellables: Set<AnyCancellable> = .init()
    
    @State var data: BLEData = .init(command: "set", password: "", fb_login: "test@example.com", fb_password: "104931", fb_user_id: "")
    
    
    init(network: WifiNetwork, vm: DeviceViewModel) {
        self.network = network
        self.vm = vm
    }
    
    
    
    var body: some View {
        NavigationView {
            if vm.connectionState == .bluetoothConnected {
                VStack {
                    
                    SecureInputField("Password", text: $data.password.toUnwrapped(defaultValue: ""))
                        .frame(height: 55)
                        .cornerRadius(8)
                    
                    Button {
                        if data.password != nil {
                            data.SSID = network.SSID
                            data.fb_user_id = authState.user!.uid
                            vm.write(data.toData()!)
                            vm.connectionState = .wifiConnection
                        }
                        
                    } label: {
                        Text("Connect")
                            .bold()
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(data.password!.isEmpty ? .secondary : Color("AccentColor"))
                            .disabled(data.password!.isEmpty)
                            .cornerRadius(8)
                            .accessibilityLabel("Connect wi-fi")
                            .padding(.top, 46)
                    }
                    
                    
                    Spacer()
                }
                .padding()
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle(network.SSID)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                                        Button {
                                            presentationMode.wrappedValue.dismiss()
                                        } label: {
                                            Image(systemName: "multiply")
                                                .foregroundColor(.black)
                                        }
                                    }
                                }
            } else if vm.connectionState == .wifiConnection {
                VStack(spacing: 0) {
                    Image("BluetoothLockerImage")
                        .padding(.top, 90)
                    GIFView(type: .name("wi-fi"))
                        .frame(width: 255, height: 221)
                }
                .navigationTitle("Locker connection")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                                        Button {
                                            presentationMode.wrappedValue.dismiss()
                                        } label: {
                                            Image(systemName: "multiply")
                                                .foregroundColor(.black)
                                        }
                                    }
                                }
            }
        }
        .onAppear {
            vm.$connectionState
                .sink { state in
                    if state == .connected {
                        presentationMode.wrappedValue.dismiss()
                        vm.peripheral.readValue(for: vm.serialNumberCharacteristic!)
                    }
                }
                .store(in: &cancellables)
            
            vm.$serial
                .sink { serial in
                    guard let serial = serial else {
                        print(serial)
                        return
                    }
                    
                    authState.updateLocker(lockerId: serial)
                    keysVM.createMainKey(serial: serial)
                }
                .store(in: &cancellables)
        }
        .errorAlert(error: $vm.error)
    }
}

struct AuthDeviceView_Previews: PreviewProvider {
    static var previews: some View {
        AuthDeviceView()
    }
}
