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
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        Form  {
            Section {
                TextField("Email", text: $credentials.email)
                    .autocapitalization(.none)
            }
            Section {
                SecureField("Password", text: $credentials.password)
            }
            
            Button {
                login()
            } label: {
                Text("Sign in")
                    .font(.title3)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.white)
            }
        }
        
        HStack {
            Text("Dont have an account?")
            Button {
                showSignUp.toggle()
            } label: {
                Text("Sign up")
            }
        }
        .sheet(isPresented: $showSignUp) {
            NavigationView {
                Form  {
                    Section {
                        TextField("Email", text: $credentials.email)
                            .autocapitalization(.none)
                    }
                    Section {
                        TextField("First name", text: $lockerUser.firstName)
                        TextField("Last name", text: $lockerUser.lastName)
                        TextField("Locker ID", text: $lockerUser.lockerId)
                    }
                    Section {
                        SecureField("Password", text: $credentials.password)
                    }
                    Section {
                        SecureField("Password", text: $credentials.confirmPassword)
                    }
                    
                    Button {
                        signUp()
                    } label: {
                        Text("Sign up")
                            .font(.title3)
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                    }
                }
                .navigationBarTitle("Sign up")
                .navigationBarItems(trailing: Button(action: {
                    showSignUp.toggle()
                }, label: {
                    Image(systemName: "multiply")
                        .foregroundColor(.secondary)
                }))
            }
            
        }
        
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
