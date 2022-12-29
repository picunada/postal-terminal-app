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
                    VStack(alignment: .center, spacing: 0) {
                        Image("NotAvailable")
//                            .padding(.top)
                        Image("WifiNotAvailable")
                            .padding(.top, 20)
                        Text("Please connect your Locker first")
                            .bold()
                            .font(.custom("Not connected", size: 20))
                            .padding(.top, 60)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
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
