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
    
    @State var showCreateKey: Bool = false
    @State var newKey: LockerKey = LockerKey(keyName: "", isOneTime: false)
    @State var setExpirationDate: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(uiColor: .secondarySystemBackground).ignoresSafeArea()
                VStack(alignment: .leading) {
                    HStack {
                        Text("Keys")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Spacer()
                        Button {
                            showCreateKey.toggle()
                            print("Button clicked")
                        } label: {
                            Image(systemName: "plus")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .padding()
                                .foregroundColor(Color.white)
                                .background(Color(UIColor.systemIndigo))
                                .clipShape(Circle())
                        }
                        .sheet(isPresented: $showCreateKey) {
                            createKey
                        }

                    }
                    .padding(.top, -8)
                    
                    KeysListView(activeKeys: keyState.activeKeys, inactiveKeys: keyState.inactiveKeys, keyState: keyState)
                }
                .padding(.horizontal)
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .accentColor(.primary)
    }
    
    var createKey: some View {
        NavigationView {
            ScrollView {
                VStack {
                    Text("By creating and sharing a guest key, anyone can open Lockerbot for delivery or pickup. You can specify how long the key as active or even create a key for one-time use.").foregroundColor(.secondary)
                    TextField("Key name", text: $newKey.keyName)
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground).cornerRadius(8))
                        .autocapitalization(.none)

                    HStack {
                        Toggle(isOn: $newKey.isOneTime, label: {
                            VStack(alignment: .leading) {
                                Text("One-time use key")
                                Text("Can only be used once")
                                    .font(.callout)
                                    .foregroundColor(Color(UIColor.secondaryLabel))
                            }
                        })
                        .toggleStyle(SwitchToggleStyle(tint: Color(UIColor.systemIndigo)))
                    }
                    .padding(.top)
                    HStack {
                        Toggle(isOn: $setExpirationDate, label: {
                            VStack(alignment: .leading) {
                                Text("Set expiration date")
                                Text("Automatically deactivate key")
                                    .font(.callout)
                                    .foregroundColor(Color(UIColor.secondaryLabel))
                            }
                        })
                        .toggleStyle(SwitchToggleStyle(tint: Color(UIColor.systemIndigo)))
                    }
                    .padding(.vertical)
                    
                    
                    if setExpirationDate {
                        DatePicker("Set date", selection: Binding<Date>(get: {newKey.expirationDate ?? Date()}, set: {newKey.expirationDate = $0}), in: Date()..., displayedComponents: .date)
                            .padding(.vertical)
                            .foregroundColor(Color(UIColor.secondaryLabel))
                    }
                    VStack {
                        Button {
                            keyState.createKey(key: newKey, user: authState.lockerUser!)
                            newKey = LockerKey(keyName: "", isOneTime: false)
                            showCreateKey.toggle()
                        } label: {
                            Text("Save")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(Color.white)
                                .frame(maxWidth: .infinity)
                        }
                        .padding()
                        .background(Color(.systemIndigo).cornerRadius(8))
                        .accessibilityLabel("Save new key")
                    }
                }
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
                            NavigationLink(destination: KeysInfoView(key: key, keyState: keyState, type: "active")) {
                                HStack {
                                    VStack {
                                        Image(systemName: "key.viewfinder")
                                            .resizable()
                                            .frame(width: 50, height: 50)
                                            .foregroundColor(Color(UIColor.systemIndigo))
                                    }
                                    VStack(alignment: .leading) {
                                        Text(key.keyName)
                                            .font(.callout)
                                        if key.isOneTime {
                                            Text("One-time use key")
                                                .font(.callout)
                                                .foregroundColor(Color(UIColor.secondaryLabel))
                                        } else {
                                            Text("Multiuse key")
                                                .font(.callout)
                                                .foregroundColor(Color(UIColor.secondaryLabel))
                                        }
                                        
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }
                    } header: {
                        Text("ACTIVE")
                    }
                }
                if inactiveKeys.count != 0 {
                    Section {
                        ForEach(inactiveKeys, id: \.id) { key in
                            NavigationLink(destination: KeysInfoView(key: key, keyState: keyState, type: "inactive")) {
                                HStack {
                                    VStack {
                                        Image(systemName: "key.viewfinder")
                                            .resizable()
                                            .frame(width: 50, height: 50)
                                            .foregroundColor(Color(UIColor.systemIndigo))
                                    }
                                    VStack(alignment: .leading) {
                                        Text(key.keyName)
                                            .font(.callout)
                                        if key.isOneTime {
                                            Text("One-time use key")
                                                .font(.callout)
                                                .foregroundColor(Color(UIColor.secondaryLabel))
                                        } else {
                                            Text("Multiuse key")
                                                .font(.callout)
                                                .foregroundColor(Color(UIColor.secondaryLabel))
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }
                    } header: {
                        Text("EXPIRED")
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .listStyle(.automatic)
            .padding(.horizontal, -20)
        } else {
            List {
                if activeKeys.count != 0 {
                    Section {
                        ForEach(activeKeys, id: \.id) { key in
                            NavigationLink(destination: KeysInfoView(key: key, keyState: keyState, type: "active").edgesIgnoringSafeArea(.all)) {
                                HStack {
                                    VStack {
                                        Image(systemName: "key.viewfinder")
                                            .resizable()
                                            .frame(width: 50, height: 50)
                                            .foregroundColor(Color(UIColor.systemIndigo))
                                    }
                                    VStack(alignment: .leading) {
                                        Text(key.keyName)
                                            .font(.callout)
                                        if key.isOneTime {
                                            Text("One-time use key")
                                                .font(.callout)
                                                .foregroundColor(Color(UIColor.secondaryLabel))
                                        } else {
                                            Text("Multiuse key")
                                                .font(.callout)
                                                .foregroundColor(Color(UIColor.secondaryLabel))
                                        }
                                        
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }
                    } header: {
                        Text("ACTIVE")
                    }
                }
                if inactiveKeys.count != 0 {
                    Section {
                        ForEach(inactiveKeys, id: \.id) { key in
                            NavigationLink(destination: KeysInfoView(key: key, keyState: keyState, type: "inactive").edgesIgnoringSafeArea(.all)) {
                                HStack {
                                    VStack {
                                        Image(systemName: "key.viewfinder")
                                            .resizable()
                                            .frame(width: 50, height: 50)
                                            .foregroundColor(Color(UIColor.systemIndigo))
                                    }
                                    VStack(alignment: .leading) {
                                        Text(key.keyName)
                                            .font(.callout)
                                        if key.isOneTime {
                                            Text("One-time use key")
                                                .font(.callout)
                                                .foregroundColor(Color(UIColor.secondaryLabel))
                                        } else {
                                            Text("Multiuse key")
                                                .font(.callout)
                                                .foregroundColor(Color(UIColor.secondaryLabel))
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }
                    } header: {
                        Text("EXPIRED")
                    }
                }
            }
            .onAppear(perform: {
                        // cache the current background color
                        UITableView.appearance().backgroundColor = UIColor.clear
                    })
            .listStyle(.automatic)
            .padding(.horizontal, -20)
        }
    }
}

//struct KeysView_Previews: PreviewProvider {
//    static var previews: some View {
//        KeysView()
//    }
//}
