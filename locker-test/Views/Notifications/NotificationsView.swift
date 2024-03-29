//
//  NotificationsView.swift
//  locker-test
//
//  Created by Danil Bezuglov on 10/17/22.
//

import SwiftUI

struct NotificationsView: View {
    @EnvironmentObject var notificationsManager: NotificationsManager
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(uiColor: .secondarySystemBackground).ignoresSafeArea()
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Text("Notifications")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Spacer()
                        Button {
                            print("Button clicked")
                        } label: {
                            Text("Clear all")
                        }
                    }
                    .frame(height: 55)
                    .padding(.horizontal)
                    
                    if notificationsManager.notifications.isEmpty {
                        EmptyNotificationsView()
                    } else {
                        NotificationsListView()
                    }
                }
                .onAppear {
                    notificationsManager.reloadAuthorizationStatus()
                }
                .onChange(of: notificationsManager.authorizationStatus, perform: { authorizationStatus in
                    switch authorizationStatus {
                    case .notDetermined:
                        notificationsManager.requestAuthorization()
                    case .authorized:
                        notificationsManager.reloadLocalNotifications()
                    default:
                        break
                    }
                })
                .padding(.top, 40)
                .padding(.bottom, 50)
            }
            .navigationBarTitle("")
            .navigationBarHidden(true)
            .navigationBarTitleDisplayMode(.inline)
        }
        .accentColor(.primary)
    }
}

struct NotificationsListView: View {
    
    @EnvironmentObject var notificationsManager: NotificationsManager
    
    var body: some View {
        if #available(iOS 16.0, *) {
            List {
                ForEach(notificationsManager.notifications, id: \.identifier) { notification in
                    HStack {
                        VStack {
                            Image(systemName: "shippingbox")
                                .resizable()
                                .frame(width: 25, height: 25)
                                .padding()
                                .foregroundColor(Color(UIColor.systemIndigo))
                        }
                        .frame(width: 41, height: 41)
                        .overlay(Circle().stroke(.secondary, lineWidth: 1))
                        
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text(notification.content.title)
                            Text(notification.content.body)
                                .foregroundColor(Color(UIColor.secondaryLabel))
                        }
                        .padding(.leading)
                        
                        Spacer()
                        
                        Button {
                            //
                        } label: {
                            Image(systemName: "trash")
                                .resizable()
                                .foregroundColor(.secondary)
                                .frame(width: 21, height: 23)
                                .padding(.trailing, 8)
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }
                    .listRowInsets(EdgeInsets())
                    .padding(.vertical)
                    .padding(.horizontal)
                }
                .onDelete(perform: notificationsManager.deleteNotificationIS)
            }
            .scrollContentBackground(.hidden)
        } else {
            // Fallback on earlier versions
            List {
                ForEach(notificationsManager.notifications, id: \.identifier) { notification in
                    HStack {
                        VStack {
                            Image(systemName: "shippingbox")
                                .resizable()
                                .frame(width: 25, height: 25)
                                .padding()
                                .foregroundColor(Color(UIColor.systemIndigo))
                        }
                        .frame(width: 41, height: 41)
                        .overlay(Circle().stroke(.secondary, lineWidth: 1))
                        
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text(notification.content.title)
                            Text(notification.content.body)
                                .foregroundColor(Color(UIColor.secondaryLabel))
                        }
                        .padding(.leading)
                        
                        Spacer()
                        
                        Button {
                            //
                        } label: {
                            Image(systemName: "trash")
                                .resizable()
                                .foregroundColor(.secondary)
                                .frame(width: 21, height: 23)
                                .padding(.trailing, 8)
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }
                    .listRowInsets(EdgeInsets())
                    .padding(.vertical)
                    .padding(.horizontal)
                }
                .onDelete(perform: notificationsManager.deleteNotificationIS)
            }
            .onAppear(perform: {
                        // cache the current background color
                        UITableView.appearance().backgroundColor = UIColor.clear
                    })
        }
    }
}

// MARK: Empty view

struct EmptyNotificationsView: View {
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Image("EmptyNotifications")
                .padding(.top, 176)
            Text("There are currently no notifications")
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

struct NotificationsView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyNotificationsView()
    }
}
