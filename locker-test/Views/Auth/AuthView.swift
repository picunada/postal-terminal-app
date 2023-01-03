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
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 0) {
                    Image("Logo")
                        .frame(width: 269, height: 55)
                        .padding(.top, 97)
                        .padding(.bottom, 60)
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
                        .frame(height: 200)
                        .scrollDisabled(true)
                        .scrollContentBackground(.hidden)
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
                        .frame(height: 200)
                        .onAppear {
                            UITableView.appearance().backgroundColor = .clear
                            UITableView.appearance().isScrollEnabled = false

                        }
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
                    .background(Color("AccentColor"))
                    .cornerRadius(10)
                    .padding(.horizontal, 16)
                    .padding(.top, 30)
                    
                    Spacer()
                    // MARK: Sign up
                    
                    VStack(spacing: 19) {
                        Text("Dont have an account?")
                        Button {
                            showSignUp.toggle()
                        } label: {
                            Text("Sign up")
                        }
                    }
                    .frame(height: 76)
                    .padding(.bottom, 40)
                    .sheet(isPresented: $showSignUp) {
                        NavigationView {
                            ScrollView {
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
                                        .frame(height: 370)
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
                                        .frame(height: 370)
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
                                        signUp()
                                    } label: {
                                        Text("Sign up")
                                            .font(.title3)
                                            .frame(maxWidth: .infinity)
                                            .foregroundColor(.white)
                                            .padding()
                                    }
                                    .background((credentials.password.isEmpty || credentials.confirmPassword.isEmpty || lockerUser.firstName.isEmpty || lockerUser.lastName.isEmpty || credentials.email.isEmpty) ? .secondary : Color("AccentColor"))
                                    .cornerRadius(8)
                                    .padding(.horizontal, 16)
                                    .padding(.bottom, 50)
                                    .disabled((credentials.password.isEmpty || credentials.confirmPassword.isEmpty || lockerUser.firstName.isEmpty || lockerUser.lastName.isEmpty || credentials.email.isEmpty))
                                    
                                    Spacer()
                                }
                            }
                        }
                        .errorAlert(error: $authState.error)
                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
        .ignoresSafeArea(.keyboard)
        .errorAlert(error: $authState.error)
    }
    
    func login() {
        Auth.auth().signIn(withEmail: credentials.email, password: credentials.password) { (auth, error) in
            if let error = error as NSError? {
                let code = AuthErrorCode(_nsError: error)
                switch code.code {
                case .emailAlreadyInUse:
                    authState.error = FBAuthError.emailAlreadyInUse
                case .missingEmail:
                    authState.error = FBAuthError.missingEmail
                default:
                    authState.error = FBAuthError.defaultAuthError
                }
            }
        }
    }
    
    func signUp() {
        if credentials.password == credentials.confirmPassword {
            Auth.auth().createUser(withEmail: credentials.email, password: credentials.password) { result, error in
                if let error = error as NSError? {
                    let code = AuthErrorCode(_nsError: error)
                    switch code.code {
                    case .emailAlreadyInUse:
                        authState.error = FBAuthError.emailAlreadyInUse
                    case .missingEmail:
                        authState.error = FBAuthError.missingEmail
                    default:
                        authState.error = FBAuthError.defaultSignUpError
                    }
                }
                if (result != nil) {
                    authState.createUser(userId: (result?.user.uid)!, user: lockerUser)
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
