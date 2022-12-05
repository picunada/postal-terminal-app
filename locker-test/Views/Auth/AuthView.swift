//
//  AuthView.swift
//  locker-test
//
//  Created by Danil Bezuglov on 10/15/22.
//

import SwiftUI
import Firebase

struct Login {
    var email: String
    var password: String
    var confirmPassword: String
}

struct AuthView: View {
    @EnvironmentObject var authState: AuthViewModel
    
    @State var credentials: Login = Login(email: "", password: "", confirmPassword: "")
    @State var lockerUser: LockerUser = LockerUser(firstName: "", lastName: "", lockerId: "")
    @State var showSignUp: Bool = false
    
    var body: some View {
        VStack {
            Image("Logo")
                .frame(width: 269, height: 55)
                .padding(.top, 80)
                .padding(.bottom, 50)
            if #available(iOS 16.0, *) {
                Form  {
                    Section {
                        TextInputField("Email", text: $credentials.email)
                    }
                    .listRowInsets(EdgeInsets())
                    Section {
                        SecureInputField("Password", text: $credentials.password)
                    }
                    .listRowInsets(EdgeInsets())
                }
                .scrollContentBackground(.hidden)
                .padding(.bottom, 46) 
            } else {
                // Fallback on earlier versions
                Form  {
                    Section {
                        TextInputField("Email", text: $credentials.email)
                    }
                    .listRowInsets(EdgeInsets())
                    Section {
                        SecureInputField("Password", text: $credentials.password)
                    }
                    .listRowInsets(EdgeInsets())
                }
                .onAppear {
                    UITableView.appearance().backgroundColor = .clear
                }
                .padding(.bottom, 46)
            }
            
            Button {
                login()
            } label: {
                Text("Sign in")
                    .bold()
                    .font(.title3)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.white)
                    .padding()
            }
            .background(Color(.systemIndigo))
            .cornerRadius(10)
            .padding(.bottom, 100)
            .padding(.horizontal)
            
            
            VStack {
                Text("Dont have an account?")
                    .padding(.bottom, 19)
                Button {
                    showSignUp.toggle()
                } label: {
                    Text("Sign up")
                }
            }
            .padding(.bottom, 40)
            .sheet(isPresented: $showSignUp) {
                NavigationView {
                    VStack {
                        if #available(iOS 16.0, *) {
                            
                            
                            Form  {
                                Section("Personal info") {
                                    TextInputField("First name", text: $lockerUser.firstName)
                                    TextInputField("Last name", text: $lockerUser.lastName)
                                    TextInputField("Email", text: $credentials.email)
                                }
                                .listRowInsets(EdgeInsets())
                                Section("Account security") {
                                    SecureInputField("Password", text: $credentials.password)
                                    SecureInputField("Confirm password", text: $credentials.confirmPassword)
                                }
                                .listRowInsets(EdgeInsets())
                                
                            }
                            .scrollContentBackground(.hidden)
                            .navigationBarTitle("Sign up")
                            .navigationBarTitleDisplayMode(.inline)
                            .navigationBarItems(trailing: Button(action: {
                                showSignUp.toggle()
                            }, label: {
                                Image(systemName: "multiply")
                                    .foregroundColor(.primary)
                            }))
                        } else {
                            // Fallback on earlier versions
                            Form  {
                                Section("Personal info") {
                                    TextInputField("First name", text: $lockerUser.firstName)
                                    TextInputField("Last name", text: $lockerUser.lastName)
                                    TextInputField("Email", text: $credentials.email)
                                }
                                .listRowInsets(EdgeInsets())
                                Section("Account security") {
                                    SecureInputField("Password", text: $credentials.password)
                                    SecureInputField("Confirm password", text: $credentials.confirmPassword)
                                }
                                .listRowInsets(EdgeInsets())
                            }
                            .onAppear {
                                UITableView.appearance().backgroundColor = .clear
                            }
                            .navigationTitle("Sign up")
                            .navigationBarTitleDisplayMode(.inline)
                            .navigationBarItems(trailing: Button(action: {
                                showSignUp.toggle()
                            }, label: {
                                Image(systemName: "multiply")
                                    .foregroundColor(.primary)
                            }))
                        }
                        
                        Button {
                            login()
                        } label: {
                            Text("Sign in")
                                .font(.title3)
                                .frame(maxWidth: .infinity)
                                .foregroundColor(.white)
                                .padding()
                        }
                        .background(Color(.systemIndigo))
                        .cornerRadius(8)
                        .padding(.horizontal)
                        .padding(.bottom, 50)
                    }
                }
                .accentColor(.indigo)
            }
        }
        .accentColor(.indigo)
        
    }
    
    func login() {
        Auth.auth().signIn(withEmail: credentials.email, password: credentials.password)
    }
    
    func signUp() {
        if credentials.password == credentials.confirmPassword {
            Auth.auth().createUser(withEmail: credentials.email, password: credentials.password) { result, error in
                if (result != nil) {
                    lockerUser.id = result?.user.uid
                    authState.createUser(user: lockerUser)
                }
                
            }
        }
    }
}

struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        AuthView()
    }
}
