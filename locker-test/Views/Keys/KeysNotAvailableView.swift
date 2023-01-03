//
//  KeysNotAvailableView.swift
//  locker-test
//
//  Created by Danil Bezuglov on 12/28/22.
//

import SwiftUI

struct KeysNotAvailableView: View {
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

                            } label: {
                                Image(systemName: "plus")
                                    .resizable()
                                    .padding()
                                    .foregroundColor(Color.white)
                            }
                        }
                        .disabled(true)
                        .frame(width: 55, height: 55)
                        .background(.secondary)
                        .clipShape(Circle())
                        

                    }
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

