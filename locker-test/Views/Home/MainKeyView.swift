//
//  MainKeyView.swift
//  locker-test
//
//  Created by Danil Bezuglov on 12/27/22.
//

import SwiftUI

struct MainKeyView: View {
    @EnvironmentObject var keysState: KeysViewModel
    @EnvironmentObject var authState: AuthViewModel
    
    var body: some View {
        ZStack {
            Color(uiColor: .secondarySystemBackground).ignoresSafeArea()
            VStack(spacing: 0) {
                
                VStack {
                    QRView(url: "key_\(keysState.mainKey?.id ?? "null")", size: CGSize(width: 270, height: 270))
                }
                .padding()
                .frame(width: 318, height: 318)
                .background(Color(.white))
                .cornerRadius(17)
                .shadow(color: .primary.opacity(0.2), radius: 30)

                
                Spacer()
                
                Text("Main key")
                    .font(.custom("Key title", fixedSize: 28))
                    .padding(.top, 40)
                    .padding(.bottom, 15)
                
                if keysState.mainKey?.expirationDate != nil {
                    Text(formatDate(date: (keysState.mainKey?.expirationDate)!))
                        .foregroundColor(Color(UIColor.secondaryLabel))
                        .padding(.bottom, 59)
                } else {
                    Text("No expiration date")
                        .foregroundColor(Color(UIColor.secondaryLabel))
                        .padding(.bottom, 59)
                }
                
                Spacer()
            }
            .padding(.horizontal)
            
            
        }
        .onAppear {
            keysState.fetchMainKey(user: authState.lockerUser!)
        }
    }
}

struct MainKeyView_Previews: PreviewProvider {
    static var previews: some View {
        MainKeyView()
    }
}
