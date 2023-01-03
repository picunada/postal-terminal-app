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
                    if keysState.mainKey?.mainKey != nil {
                        QRView(url: "master-key_\(keysState.mainKey?.mainKey! ?? "null")", size: CGSize(width: 270, height: 270))
                    }
                    
                }
                .padding()
                .frame(width: 318, height: 318)
                .background(Color(.white))
                .cornerRadius(17)
                .shadow(color: .primary.opacity(0.2), radius: 30)
                .padding(.top, 60)

                
                Spacer()
                
                Text("Main key")
                    .font(.custom("Key title", fixedSize: 28))
                    .padding(.top, 40)
                    .padding(.bottom, 15)
                
                Text("No expiration date")
                    .foregroundColor(Color(UIColor.secondaryLabel))
                    .padding(.bottom, 59)
                
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
