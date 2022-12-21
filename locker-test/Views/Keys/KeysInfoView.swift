//
//  KeysInfoView.swift
//  locker-test
//
//  Created by Danil Bezuglov on 10/17/22.
//

import SwiftUI

struct KeysInfoView: View {
    let dateFormatter = DateFormatter()
    
    @EnvironmentObject var authState: AuthViewModel
    @ObservedObject var keyState: KeysViewModel
    
    var key: LockerKey
    var type: String
    
    init(key: LockerKey, keyState: KeysViewModel, type: String) {
        self.key = key
        self.keyState = keyState
        self.type = type
    }
    
    var body: some View {
        
        ZStack {
            Color(uiColor: .secondarySystemBackground).ignoresSafeArea()
            VStack(spacing: 0) {
//                Spacer()
                
                VStack {
                    
                }
                .frame(width: 250, height: 250)
                .background(Color(.white))
                .cornerRadius(17)
                .shadow(color: .primary.opacity(0.2), radius: 30)
                .padding(.top, 50)
                
                Text(key.keyName.capitalized)
                    .font(.custom("Key title", fixedSize: 28))
                    .padding(.top, 40)
                    .padding(.bottom, 15)
                
                if key.expirationDate != nil {
                    Text(formatDate(date: key.expirationDate!))
                        .foregroundColor(Color(UIColor.secondaryLabel))
                        .padding(.bottom, 59)
                } else {
                    Text("No expiration date")
                        .foregroundColor(Color(UIColor.secondaryLabel))
                        .padding(.bottom, 59)
                }
                
                Button {
                    
                } label: {
                    Text("Share guest key")
                        .font(.title3)
                        .bold()
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.white)
                        .padding()
                }
                .frame(height: 48)
                .background(Color("AccentColor"))
                .cornerRadius(8)
                
                Spacer()
                
                Button {
                    keyState.deleteKey(key: key, user: authState.lockerUser!, type: type)
                } label: {
                    VStack {
                        HStack(alignment: .firstTextBaseline) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                            Text("Delete guest key")
                                .font(.title2)
                                .foregroundColor(.primary)
                        }
                    }
                }
                .tint(.clear)
                .padding()
                .padding(.bottom, 53)
                .accessibilityLabel("Delete parcel")
            }
            .padding(.horizontal)
        }
    }
    
    func formatDate(date: Date) -> String {
        dateFormatter.dateFormat = "YY/MM/dd"
        let date = dateFormatter.string(from: key.expirationDate!)
        return date
    }
}

//struct KeysInfoView_Previews: PreviewProvider {
//    static var previews: some View {
//        KeysInfoView(key: LockerKey(keyName: "test", isOneTime: false, expirationDate: Date()))
//    }
//}
