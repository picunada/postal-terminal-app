//
//  NotificationsView.swift
//  locker-test
//
//  Created by Danil Bezuglov on 10/17/22.
//

import SwiftUI

struct NotificationsView: View {
    var body: some View {
        NavigationView {
            ZStack {
                Color(uiColor: .secondarySystemBackground).ignoresSafeArea()
                VStack(alignment: .leading) {
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
                    .padding(.top, 3)
                    
                    NotificationsListView()
                }
                .padding(.horizontal)
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .accentColor(.primary)
    }
}

struct NotificationsListView: View {
    var body: some View {
        if #available(iOS 16.0, *) {
            List {
                HStack {
                    VStack {
                        Image(systemName: "shippingbox")
                            .resizable()
                            .frame(width: 25, height: 25)
                            .padding()
                            .foregroundColor(Color(UIColor.systemIndigo))
                            .background(Color(UIColor.systemBackground))
                            .clipShape(Circle())
                    }
                    VStack(alignment: .leading) {
                        Text("DHL")
                            .font(.callout)
                        Text("Delivered today, 10:22")
                            .font(.callout)
                            .foregroundColor(Color(UIColor.secondaryLabel))
                    }
                    .padding(.horizontal)
                    Spacer()
                    Button {
                        //
                    } label: {
                        Image(systemName: "trash")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                }
                .padding(.trailing, 20)
            }
            .scrollContentBackground(.hidden)
            .listStyle(.automatic)
            .padding(.horizontal, -20)
        } else {
            // Fallback on earlier versions
            List {
                HStack {
                    VStack {
                        Image(systemName: "shippingbox")
                            .resizable()
                            .frame(width: 25, height: 25)
                            .padding()
                            .foregroundColor(Color(UIColor.systemIndigo))
                            .background(Color(UIColor.systemBackground))
                            .clipShape(Circle())
                    }
                    VStack(alignment: .leading) {
                        Text("DHL")
                            .font(.callout)
                        Text("Delivered today, 10:22")
                            .font(.callout)
                            .foregroundColor(Color(UIColor.secondaryLabel))
                    }
                    .padding(.horizontal)
                    Spacer()
                    Button {
                        //
                    } label: {
                        Image(systemName: "trash")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(BorderlessButtonStyle())

                }
                .padding(.trailing, 20)
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

struct NotificationsView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationsView()
    }
}
