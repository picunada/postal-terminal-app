//
//  ProfileView.swift
//  locker-test
//
//  Created by Danil Bezuglov on 10/17/22.
//

import SwiftUI
import Firebase
import Combine

struct ProfileView: View {
    @State var showPersonalInfo: Bool = false
    @State var showLockerInfo: Bool = false
    @State var showSecurity: Bool = false
    @State var showAlert: Bool = false
    @State var cancellables: Set<AnyCancellable> = .init()
    
    @StateObject private var telemetryVM: TelemetryViewModel = .init()
    
    @EnvironmentObject var authState: AuthViewModel
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(uiColor: .secondarySystemBackground).ignoresSafeArea()
                VStack(spacing: 0) {
                    List {
                        Button {
                            self.showPersonalInfo.toggle()
                        } label: {
                            HStack {
                                Text("Personal Information")
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .resizable()
                                    .frame(width: 7, height: 12)
                                    .foregroundColor(Color(.secondaryLabel))
                            }
                        }
                        .sheet(isPresented: $showPersonalInfo, content: {
                            PersonalInfoView(show: $showPersonalInfo, email: authState.user!.email!, user: authState.lockerUser!)
                        })
                        .listRowInsets(EdgeInsets())
                        .padding() 
                        
                        
                        Button {
                            self.showLockerInfo.toggle()
                        } label: {
                            HStack {
                                Text("Locker information")
                                        
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .resizable()
                                    .frame(width: 7, height: 12)
                                    .foregroundColor(Color(.secondaryLabel))
                            }
                        }
                        .disabled(authState.lockerUser == nil || (authState.lockerUser?.lockerId?.isEmpty) == true)
                        .sheet(isPresented: $showLockerInfo, content: {
                            if let telemetry = telemetryVM.telemetry {
                                LockerInfoView(show: $showLockerInfo, telemetryVM: telemetryVM, telemetry: telemetry)
                            }
                        })
                        .listRowInsets(EdgeInsets())
                        .padding()
                        
                        Button {
                            self.showSecurity.toggle()
                        } label: {
                            HStack {
                                Text("Account security")
                                        
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .resizable()
                                    .frame(width: 7, height: 12)
                                    .foregroundColor(Color(.secondaryLabel))
                            }
                        }
                        .sheet(isPresented: $showSecurity, content: {
                            AccountSecurityView(show: $showSecurity)
                        })
                        .listRowInsets(EdgeInsets())
                        .padding()
                    }
                    .frame(height: 210)
                    .padding(.horizontal, -20)
                    
                    Button {
                        showAlert.toggle()
                    } label: {
                        Text("Log out")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(Color.red)
                            .frame(maxWidth: .infinity)
                    }
                    .frame(height: 48)
                    .padding(.horizontal)
                    .background(Color(uiColor: .systemBackground))
                    .cornerRadius(8)
                    .accessibilityLabel("Log out")
                    .confirmationDialog("Are you sure>", isPresented: $showAlert, actions: {
                        Button(role: .destructive) {
                            authState.logout()
                        } label: {
                            Text("Log out")
                        }
                    }, message: {
                        Text("Are you sure you want to Log out?")
                    })
                    Spacer()
                }
                .padding(.top)
                .padding(.horizontal)
                .padding(.bottom)
            }
            .onAppear {
                authState.$lockerUser
                    .filter({ user in
                        return user != nil
                    })
                    .sink { user in
                        telemetryVM.subscribe(user: user!)
                    }
                    .store(in: &cancellables)
            }
            .navigationTitle("Profile")
        }
    }
}

// MARK: Personal Info

struct PersonalInfoView: View {
    
    @Binding var show: Bool
    
    @EnvironmentObject var authState: AuthViewModel
    
    @State var email: String
    @State var user: LockerUser
    @State var isChanged: Bool = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if #available(iOS 16.0, *) {
                    
                    Form(content: {
                        Section("First name") {
                            TextInputField("First name", text: $user.firstName)
                                .onChange(of: user.firstName) { newValue in
                                    isChanged = true
                                }
                        }
                        .listRowInsets(EdgeInsets())
                        Section("Last name") {
                            TextInputField("Last name", text: $user.lastName)
                                .onChange(of: user.lastName) { newValue in
                                    isChanged = true
                                }
                        }
                        .listRowInsets(EdgeInsets())
                        Section("Email") {
                            TextInputField("Email", text: $email)
                                .disabled(true)
                        }
                        .listRowInsets(EdgeInsets())
                    })
                    .frame(height: 310)
                    .scrollContentBackground(.hidden)
                } else {
                    // Fallback on earlier versions
                    Form(content: {
                        Section("First name") {
                            TextInputField("First name", text: $user.firstName)
                                .onChange(of: user.firstName) { newValue in
                                    isChanged = true
                                }
                        }
                        .listRowInsets(EdgeInsets())
                        Section("Last name") {
                            TextInputField("Last name", text: $user.lastName)
                                .onChange(of: user.lastName) { newValue in
                                    isChanged = true
                                }
                        }
                        .listRowInsets(EdgeInsets())
                        Section("Email") {
                            TextInputField("Email", text: $email)
                                .foregroundColor(.secondary)
                                .disabled(true)
                        }
                        .listRowInsets(EdgeInsets())
                    })
                    .frame(height: 310)
                    .onAppear {
                        UITableView.appearance().backgroundColor = .clear
                    }
                }
                
                VStack {
                    Button {
                        authState.updateUserInfo(lockerUser: user)
                        authState.fetchUser(userId: authState.user!.uid )
                        show.toggle()
                    } label: {
                        Text("Save")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(Color.white)
                            .frame(maxWidth: .infinity)
                    }
                    .frame(height: 48)
                    .padding(.horizontal)
                    .background(isChanged ? Color("AccentColor") : .secondary)
                    .disabled(!isChanged)
                    .cornerRadius(8)
                    .accessibilityLabel("Update profile info")
                }
                .padding(.horizontal)
                .padding(.top, 34)
                
                Spacer()
            }
            .padding(.horizontal, 0)
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Edit personal information ")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                                    Button {
                                        show.toggle()
                                    } label: {
                                        Image(systemName: "multiply")
                                            .foregroundColor(.black)
                                    }
                                }
                            }
        }
    }
}

// MARK: Locker Info

struct LockerInfoView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var show: Bool
    @EnvironmentObject var authState: AuthViewModel
    
    @ObservedObject var telemetryVM: TelemetryViewModel
    
    @State var telemetry: LockerTelemetry
    @State var isChanged: Bool = false
    @State var cancellables: Set<AnyCancellable> = .init()
    
    var body: some View {
        NavigationView {
            VStack {
                if #available(iOS 16.0, *) {
                    Form {
                        Section("Address") {
                            TextInputField("Address", text: $telemetry.address.toUnwrapped(defaultValue: ""))
                                .onChange(of: telemetry.address) { newValue in
                                    isChanged = true
                                }
                        }
                        .listRowInsets(EdgeInsets())
                        Section("Locker's name") {
                            TextInputField("Locker's name", text: $telemetry.name.toUnwrapped(defaultValue: ""))
                                .onChange(of: telemetry.name) { newValue in
                                    isChanged = true
                                }
                        }
                        .listRowInsets(EdgeInsets())
                    }
                    .frame(height: 210)
                    .scrollContentBackground(.hidden)
                } else {
                    // Fallback on earlier versions
                    Form {
                        Section("Address") {
                            TextInputField("Address", text: $telemetry.address.toUnwrapped(defaultValue: ""))
                                .onChange(of: telemetry.address) { newValue in
                                    isChanged = true
                                }
                        }
                        .listRowInsets(EdgeInsets())
                        Section("Locker's name") {
                            TextInputField("Locker's name", text: $telemetry.name.toUnwrapped(defaultValue: ""))
                                .onChange(of: telemetry.name) { newValue in
                                    isChanged = true
                                }
                        }
                        .listRowInsets(EdgeInsets())
                    }
                    .frame(height: 210)
                    .onAppear {
                        UITableView.appearance().backgroundColor = .clear
                    }
                }
                
                VStack {
                    Button {
                        telemetryVM.updateLockerInfo((authState.lockerUser?.lockerId)!, telemetry: telemetry)
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Text("Save")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(Color.white)
                            .frame(maxWidth: .infinity)
                    }
                    .frame(height: 48)
                    .padding(.horizontal)
                    .background(isChanged ? Color("AccentColor") : .secondary)
                    .disabled(!isChanged)
                    .cornerRadius(8)
                    .accessibilityLabel("Update profile info")
                }
                .padding(.horizontal)
                .padding(.top, 34)
                
                Spacer()
            }
            .padding(.horizontal, 0)
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Edit locker information ")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                                    Button {
                                        show.toggle()
                                    } label: {
                                        Image(systemName: "multiply")
                                            .foregroundColor(.black)
                                    }
                                }
                            }
        }
    }
}

struct AccountSecurityView: View {

    @Binding var show: Bool
    @State var reAuthCredentials: FirebaseCredentials = .init(email: "", password: "")
    @State var credentials: ChangePasswordCredentials = .init(password: "", confirmPassword: "")

    @EnvironmentObject var authState: AuthViewModel
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    if #available(iOS 16.0, *) {
                        Form {
                            Section("Current password") {
                                SecureInputField("Current passowrd", text: $reAuthCredentials.password.toUnwrapped(defaultValue: ""))
                                    .cornerRadius(8)
                            }
                            .listRowInsets(EdgeInsets())
                            
                            Section("New password") {
                                SecureInputField("New passowrd", text: $credentials.password.toUnwrapped(defaultValue: ""))
                                    .cornerRadius(8)
                            }
                            .listRowInsets(EdgeInsets())
                            
                            Section("Confirm password") {
                                SecureInputField("Confirm passowrd", text: $credentials.confirmPassword.toUnwrapped(defaultValue: ""))
                                    .cornerRadius(8)
                            }
                            .listRowInsets(EdgeInsets())
                        }
                        .scrollDisabled(true)
                        .frame(height: 310)
                        .scrollContentBackground(.hidden)
                        
                    } else {
                        // Fallback on earlier versions
                        Form {
                            Section("Current password") {
                                SecureInputField("Current passowrd", text: $reAuthCredentials.password.toUnwrapped(defaultValue: ""))
                                    .cornerRadius(8)
                            }
                            .listRowInsets(EdgeInsets())
                            
                            Section("New password") {
                                SecureInputField("New passowrd", text: $credentials.password.toUnwrapped(defaultValue: ""))
                                    .cornerRadius(8)
                            }
                            .listRowInsets(EdgeInsets())
                            
                            Section("Confirm password") {
                                SecureInputField("Confirm passowrd", text: $credentials.confirmPassword.toUnwrapped(defaultValue: ""))
                                    .cornerRadius(8)
                            }
                            .listRowInsets(EdgeInsets())
                        }
                        .frame(height: 310)
                        .onAppear {
                            UITableView.appearance().backgroundColor = .clear
                        }
                    }
                    
                    VStack {
                        Button {
                            reAuthCredentials.email = authState.user?.email
                            let credential = EmailAuthProvider.credential(withEmail: reAuthCredentials.email ?? "", password: reAuthCredentials.password ?? "")
                            authState.updatePassword(credential, credentials: credentials)
                        } label: {
                            Text("Save")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(Color.white)
                                .frame(maxWidth: .infinity)
                        }
                        .frame(height: 48)
                        .padding(.horizontal)
                        .background((reAuthCredentials.password!.isEmpty || credentials.password!.isEmpty || credentials.confirmPassword!.isEmpty) ? .secondary : Color("AccentColor"))
                        .disabled(reAuthCredentials.password!.isEmpty || credentials.password!.isEmpty || credentials.confirmPassword!.isEmpty)
                        .cornerRadius(8)
                        .accessibilityLabel("Save password")
                    }
                    .padding(.horizontal)
                    .padding(.top, 34)
                    
                    Spacer()

                }
                .alert("Change password", isPresented: $authState.updateSuccess, actions: {
                    
                }, message: {
                    Text("Successfuly changed password")
                })
                .errorAlert(error: $authState.error)
                .padding(.horizontal, 0)
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle("Account security")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                                        Button {
                                            show.toggle()
                                        } label: {
                                            Image(systemName: "multiply")
                                                .foregroundColor(.black)
                                        }
                                    }
                                }
            }
        }
        .errorAlert(error: $authState.error)
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
