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
        
        NavigationView {
            ZStack {
                Color(uiColor: .secondarySystemBackground).ignoresSafeArea()
                VStack {
                    Rectangle()
                        .frame(width: 250, height: 250)
                        .foregroundColor(.white).cornerRadius(17)
                        .shadow(color: .primary.opacity(0.2), radius: 30)
                    Text(key.keyName.capitalized)
                        .font(.largeTitle)
                        .padding(.top, 30)
                    if key.expirationDate != nil {
                        Text(formatDate(date: key.expirationDate!))
                            .font(.title3)
                            .foregroundColor(Color(UIColor.secondaryLabel))
                            .padding(.top, -10)
                            .padding(.bottom, 30)
                    } else {
                        Text("No expiration date")
                            .font(.title3)
                            .foregroundColor(Color(UIColor.secondaryLabel))
                            .padding(.top, -10)
                            .padding(.bottom, 30)
                    }
                    VStack {
                        Button {
                            
                        } label: {
                            Text("Share guest key")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(Color.white)
                                .frame(maxWidth: .infinity)
                        }
                        .padding()
                        .background(Color(UIColor.systemIndigo).cornerRadius(8))
                        .accessibilityLabel("Share guest key")
                    }
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
                    .accessibilityLabel("Delete parcel")
                }
                .padding(.horizontal)
                .padding(.top, -150)
            }
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
