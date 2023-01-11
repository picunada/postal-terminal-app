//
//  KeysView.swift
//  locker-test
//
//  Created by Danil Bezuglov on 10/17/22.
//

import SwiftUI

struct KeysView: View {
    
    @EnvironmentObject var authState: AuthViewModel
    @ObservedObject var keyState: KeysViewModel
    
    @State private var calendarId: Int = 0
    
    @State var showCreateKey: Bool = false
    @State var newKey: LockerKey = LockerKey(keyName: "", isOneTime: false)
    @State var setExpirationDate: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(uiColor: .secondarySystemBackground).ignoresSafeArea()
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Text("Keys")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Spacer()
                        VStack {
                            Button {
                                showCreateKey.toggle()
                                print("Button clicked")
                            } label: {
                                Image(systemName: "plus")
                                    .resizable()
                                    .padding()
                                    .foregroundColor(Color.white)
                            }
                            .sheet(isPresented: $showCreateKey) {
                                createKey
                            }
                        }
                        .frame(width: 55, height: 55)
                        .background(Color("AccentColor"))
                        .clipShape(Circle())
                        

                    }
                    .padding(.top, 40)
                    .padding(.bottom, 50)
                    
                    if (keyState.activeKeys.isEmpty && keyState.inactiveKeys.isEmpty) {
                        EmptyKeysView()
                    } else {
                        KeysListView(activeKeys: keyState.activeKeys, inactiveKeys: keyState.inactiveKeys, keyState: keyState)
                    }
                }
                .padding(.horizontal)
            }
            .navigationBarTitle("")
            .navigationBarHidden(true)
            .navigationBarTitleDisplayMode(.inline)
        }
        .accentColor(.primary)
    }
    
    var createKey: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    Text("By creating and sharing a guest key, anyone can open Lockerbot for delivery or pickup. You can specify how long the key as active or even create a key for one-time use.").foregroundColor(.secondary)
                        .padding(.top, 40)
                    
                    VStack {
                        TextInputField("Key name", text: $newKey.keyName)
                            .cornerRadius(8)
                    }
                    .padding(.top, 35)

                    HStack {
                        Toggle(isOn: $newKey.isOneTime, label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("One-time use key")
                                Text("Can only be used once")
                                    .font(.callout)
                                    .foregroundColor(Color(UIColor.secondaryLabel))
                            }
                        })
                        .toggleStyle(SwitchToggleStyle(tint: Color("AccentColor")))
                    }
                    .padding(.top, 25)
                    
                    HStack {
                        Toggle(isOn: $setExpirationDate, label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Set expiration date")
                                Text("Automatically deactivate key")
                                    .font(.callout)
                                    .foregroundColor(Color(UIColor.secondaryLabel))
                            }
                        })
                        .toggleStyle(SwitchToggleStyle(tint: Color("AccentColor")))
                    }
                    .padding(.top, 25)
                    
                    if setExpirationDate {
                        DatePicker("Set date", selection: Binding<Date>(get: {newKey.expirationDate ?? Date()}, set: {newKey.expirationDate = $0}), in: Date()..., displayedComponents: .date)
                            .id(calendarId)
                            .onChange(of: newKey.expirationDate, perform: { _ in
                              calendarId += 1
                            })
                            .padding(.top)
                            .foregroundColor(Color(UIColor.secondaryLabel))
                    }
                    
                    
                    Button {
                        keyState.createKey(key: newKey, user: authState.lockerUser!)
                        newKey = LockerKey(keyName: "", isOneTime: false)
                        setExpirationDate = false
                        showCreateKey.toggle()
                    } label: {
                        Text("Create a key")
                            .font(.title3)
                            .bold()
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                            .padding()
                    }
                    .disabled(newKey.keyName.isEmpty)
                    .frame(height: 48)
                    .background(newKey.keyName.isEmpty ? .secondary : Color("AccentColor"))
                    .cornerRadius(8)
                    .padding(.top, 93)
                    
                    Spacer()
                }
                .animation(.default, value: setExpirationDate)
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Create key")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                                    Button {
                                        showCreateKey.toggle()
                                    } label: {
                                        Image(systemName: "multiply")
                                            .foregroundColor(.black)
                                    }
                                }
                            }
        }
    }
}

struct KeysListView: View {
    
    @ObservedObject var keyState: KeysViewModel
    @EnvironmentObject var authState: AuthViewModel
    
    var activeKeys: [LockerKey]
    var inactiveKeys: [LockerKey]
    
    init(activeKeys: [LockerKey], inactiveKeys: [LockerKey], keyState: KeysViewModel) {
        self.activeKeys = activeKeys
        self.inactiveKeys = inactiveKeys
        self.keyState = keyState
        
        UITableViewCell.appearance().backgroundColor = UIColor(Color.clear)
        UITableView.appearance().backgroundColor = UIColor(Color.clear)
    }
    
    
    var body: some View {
        if #available(iOS 16.0, *) {
            List {
                if activeKeys.count != 0 {
                    Section {
                        ForEach(activeKeys, id: \.id) { key in
                            NavigationLink {
                                KeysInfoView(key: key, keyState: keyState, type: "active")
                                    .navigationTitle("Guest key information")
                                    .navigationBarTitleDisplayMode(.inline)
                            } label: {
                                HStack {
                                    VStack {
                                        Image(systemName: "key.viewfinder")
                                            .resizable()
                                            .frame(width: 41, height: 41)
                                            .foregroundColor(Color("AccentColor"))
                                    }
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text(key.keyName)
                                        if key.isOneTime {
                                            Text("One-time use key")
                                                .foregroundColor(Color(UIColor.secondaryLabel))
                                        } else {
                                            Text("Multiuse key")
                                                .foregroundColor(Color(UIColor.secondaryLabel))
                                        }
                                    }
                                    .padding(.leading)
                                }
                            }
                            .listRowInsets(EdgeInsets())
                            .padding()
                        }
                    } header: {
                        Text("ACTIVE")
                    }
                }
                if inactiveKeys.count != 0 {
                    Section {
                        ForEach(inactiveKeys, id: \.id) { key in
                            NavigationLink {
                                KeysInfoView(key: key, keyState: keyState, type: "inactive")
                                    .navigationTitle("Guest key information")
                                    .navigationBarTitleDisplayMode(.inline)
                            } label: {
                                HStack {
                                    VStack {
                                        Image(systemName: "key.viewfinder")
                                            .resizable()
                                            .frame(width: 41, height: 41)
                                            .foregroundColor(.secondary)
                                    }
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text(key.keyName)
                                        if key.isOneTime {
                                            Text("One-time use key")
                                                .foregroundColor(Color(UIColor.secondaryLabel))
                                        } else {
                                            Text("Multiuse key")
                                                .foregroundColor(Color(UIColor.secondaryLabel))
                                        }
                                    }
                                    .padding(.leading)
                                }
                            }
                            .listRowInsets(EdgeInsets())
                            .padding()
                        }
                    } header: {
                        Text("EXPIRED")
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .scrollContentBackground(.hidden)
            .padding(.horizontal, -20)
        } else {
            List {
                if activeKeys.count != 0 {
                    Section {
                        ForEach(activeKeys, id: \.id) { key in
                            NavigationLink {
                                KeysInfoView(key: key, keyState: keyState, type: "active")
                                    .navigationTitle("Guest key information")
                                    .navigationBarTitleDisplayMode(.inline)
                            } label: {
                                HStack {
                                    VStack {
                                        Image(systemName: "key.viewfinder")
                                            .resizable()
                                            .frame(width: 41, height: 41)
                                            .foregroundColor(Color("AccentColor"))
                                    }
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text(key.keyName)
                                        if key.isOneTime {
                                            Text("One-time use key")
                                                .foregroundColor(Color(UIColor.secondaryLabel))
                                        } else {
                                            Text("Multiuse key")
                                                .foregroundColor(Color(UIColor.secondaryLabel))
                                        }
                                    }
                                    .padding(.leading)
                                }
                            }
                            .listRowInsets(EdgeInsets())
                            .padding()
                        }
                    } header: {
                        Text("ACTIVE")
                    }
                }
                if inactiveKeys.count != 0 {
                    Section {
                        ForEach(inactiveKeys, id: \.id) { key in
                            ZStack {
                                HStack {
                                    VStack {
                                        Image(systemName: "key.viewfinder")
                                            .resizable()
                                            .frame(width: 41, height: 41)
                                            .foregroundColor(Color(UIColor.secondaryLabel))
                                    }
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text(key.keyName)
                                            .foregroundColor(Color(UIColor.secondaryLabel))
                                        if key.isOneTime {
                                            Text("One-time use key")
                                                .foregroundColor(Color(UIColor.secondaryLabel))
                                        } else {
                                            Text("Multiuse key")
                                                .foregroundColor(Color(UIColor.secondaryLabel))
                                        }
                                    }
                                    .padding(.leading)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "trash")
                                        .foregroundColor(Color(UIColor.secondaryLabel))
                                }
                                
                                NavigationLink {
                                } label: {
                                    HStack {
                                        VStack {
                                            Image(systemName: "key.viewfinder")
                                                .resizable()
                                                .frame(width: 41, height: 41)
                                                .foregroundColor(.secondary)
                                        }
                                        VStack(alignment: .leading, spacing: 5) {
                                            Text(key.keyName)
                                            if key.isOneTime {
                                                Text("One-time use key")
                                                    .foregroundColor(Color(UIColor.secondaryLabel))
                                            } else {
                                                Text("Multiuse key")
                                                    .foregroundColor(Color(UIColor.secondaryLabel))
                                            }
                                        }
                                        .padding(.leading)
                                    }
                                }
                                .opacity(0)
                                .disabled(true)
                                .listRowInsets(EdgeInsets())
                                .padding()
                            }
                        }
                        .onDelete { i in
                            keyState.delete(at: i, lockerId: (authState.lockerUser?.lockerId!)!)
                        }
                            
                    } header: {
                        Text("EXPIRED")
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .onAppear(perform: {
                        // cache the current background color
                        UITableView.appearance().backgroundColor = UIColor.clear
                    })
            .listStyle(.automatic)
            .padding(.horizontal, -20)
        }
    }
}

// MARK: Empty view

struct EmptyKeysView: View {
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Image("EmptyKeys")
                .padding(.top, 109)
            Text("You can give people one-time or recurring access to your home locker. ")
                .bold()
                .font(.custom("empty parcels", size: 17))
                .frame(width: 343)
                .multilineTextAlignment(.center)
                .padding(.top, 40)
                
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
    
}


//struct KeysView_Previews: PreviewProvider {
//    static var previews: some View {
//        EmptyKeysView()
//    }
//}
