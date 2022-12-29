//
//  NotificationsNotAvailableView.swift
//  locker-test
//
//  Created by Danil Bezuglov on 12/28/22.
//

import SwiftUI

struct NotificationsNotAvailableView: View {
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
                        .padding(.top, 40)
                        .padding(.bottom, 50)
                        EmptyNotificationsView()
                    }
                    .padding(.horizontal)
                }
                .navigationBarTitle("")
                .navigationBarHidden(true)
                .navigationBarTitleDisplayMode(.inline)
            }
            .accentColor(.primary)
        }
    }
