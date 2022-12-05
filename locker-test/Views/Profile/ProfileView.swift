//
//  ProfileView.swift
//  locker-test
//
//  Created by Danil Bezuglov on 10/17/22.
//

import SwiftUI

struct ProfileView: View {
    @State var showPersonalInfo: Bool = false
    @State var showLockerInfo: Bool = false
    @State var showSecurity: Bool = false
    
    @EnvironmentObject var authState: AuthViewModel
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(uiColor: .secondarySystemBackground).ignoresSafeArea()
                VStack {
                    List {
                        Text("Personal Information")
                                .sheet(isPresented: $showPersonalInfo, content: {
                                    PersonalInfoView(show: $showPersonalInfo)
                                })
                                .listRowInsets(EdgeInsets())
                                .padding()
                                .onTapGesture {
                                    self.showPersonalInfo.toggle()
                                }
                        Text("Locker information")
                                .sheet(isPresented: $showLockerInfo, content: {
                                    LockerInfoView(show: $showLockerInfo)
                                })
                                .listRowInsets(EdgeInsets())
                                .padding()
                                .onTapGesture {
                                    self.showLockerInfo.toggle()
                                }
//                        Text("Account security")
//                                .sheet(isPresented: $showSecurity, content: {
//                                    AccountSecurityView(show: $showSecurity)
//                                })
//                                .listRowInsets(EdgeInsets())
//                                .padding()
//                                .onTapGesture {
//                                    self.showSecurity.toggle()
//                                }
                    }
                    .padding(.horizontal, -20)
                    
                    Button {
                        authState.logout()
                    } label: {
                        Text("Log out")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(Color.red)
                            .frame(maxWidth: .infinity)
                    }
                    .padding()
                    .background(Color(uiColor: .systemBackground))
                    .cornerRadius(8)
                    .accessibilityLabel("Log out")
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .navigationTitle("Profile")
        }
    }
}

struct PersonalInfoView: View {
    
    @Binding var show: Bool
    @State var firstName: String = ""
    @State var lastName: String = ""
    @State var email: String = ""
    
    var body: some View {
        NavigationView {
            VStack {
                if #available(iOS 16.0, *) {
                    Form {
                        Section("First name") {
                            TextInputField("First name", text: $firstName)
                        }
                        .listRowInsets(EdgeInsets())
                        Section("Last name") {
                            TextInputField("Last name", text: $lastName)
                        }
                        .listRowInsets(EdgeInsets())
                        Section("Email") {
                            TextInputField("Email", text: $email)
                        }
                        .listRowInsets(EdgeInsets())
                    }
                    .scrollContentBackground(.hidden)
                } else {
                    // Fallback on earlier versions
                    Form {
                        Section("First name") {
                            TextInputField("First name", text: $firstName)
                        }
                        .listRowInsets(EdgeInsets())
                        Section("Last name") {
                            TextInputField("Last name", text: $lastName)
                        }
                        .listRowInsets(EdgeInsets())
                        Section("Email") {
                            TextInputField("Email", text: $email)
                        }
                        .listRowInsets(EdgeInsets())
                    }
                    .onAppear {
                        UITableView.appearance().backgroundColor = .clear
                    }
                }
            }
            .accentColor(.indigo)
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

struct LockerInfoView: View {
    
    @Binding var show: Bool
    @State var address: String = ""
    @State var lockerName: String = ""

    
    var body: some View {
        NavigationView {
            VStack {
                if #available(iOS 16.0, *) {
                    Form {
                        Section("Address") {
                            TextInputField("Address", text: $address)
                        }
                        .listRowInsets(EdgeInsets())
                        Section("Locker's name") {
                            TextInputField("Locker's name", text: $lockerName)
                        }
                        .listRowInsets(EdgeInsets())
                    }
                    .scrollContentBackground(.hidden)
                } else {
                    // Fallback on earlier versions
                    Form {
                        Section("Address") {
                            TextInputField("First name", text: $address)
                        }
                        .listRowInsets(EdgeInsets())
                        Section("Last name") {
                            TextInputField("Last name", text: $lockerName)
                        }
                        .listRowInsets(EdgeInsets())
                    }
                    .onAppear {
                        UITableView.appearance().backgroundColor = .clear
                    }
                }
            }
            .accentColor(.indigo)
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

//struct AccountSecurityView: View {
//
//    @Binding var show: Bool
//    @State var address: String = ""
//    @State var lockerName: String = ""
//
//
//    var body: some View {
//        NavigationView {
//            VStack {
//                Form {
//                    Section("Address") {
//                        TextInputField("First name", text: $address)
//                    }
//                    .listRowInsets(EdgeInsets())
//                    Section("Last name") {
//                        TextInputField("Last name", text: $lockerName)
//                            .padding()
//                            .background(Color(UIColor.secondarySystemBackground).cornerRadius(8))
//                            .autocapitalization(.none)
//                    }
//                    .listRowInsets(EdgeInsets())
//                }
//
//            }
//            .padding(.horizontal, 0)
//            .navigationBarTitleDisplayMode(.inline)
//            .navigationTitle("Account security")
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                                    Button {
//                                        show.toggle()
//                                    } label: {
//                                        Image(systemName: "multiply")
//                                            .foregroundColor(.black)
//                                    }
//                                }
//                            }
//        }
//    }
//}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
