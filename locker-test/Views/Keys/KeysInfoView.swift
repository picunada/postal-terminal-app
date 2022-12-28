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
    
    @State var isPresentedDeleteConfirm: Bool = false
    @State var isPresentedSharing: Bool = false
    
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
                    QRView(url: "key_\(key.id!)", size: CGSize(width: 200, height: 200))
                }
                .padding()
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
                    isPresentedSharing.toggle()
                } label: {
                    Text("Share guest key")
                        .font(.title3)
                        .bold()
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.white)
                        .padding()
                }
                .background(Color("AccentColor"))
                .cornerRadius(8)
                
                Spacer()
                
                Button {
                    isPresentedDeleteConfirm.toggle()
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
        .sheet(isPresented: $isPresentedSharing, content: {
            ShareSheet(items: [QRCodeDataSet(url: "key_\(key.id!)", backgroundColor: CIColor(color: .white), color: CIColor(color: .black), size: CGSize(width: 200, height: 200)).getQRImage()!])
        })
        .confirmationDialog("Are you sure?", isPresented: $isPresentedDeleteConfirm) {
            Button("Delete", role: .destructive) {
                keyState.deleteKey(key: key, user: authState.lockerUser!, type: type)
            }
        } message: {
            Text("Are you sure you want to delete key?")
        }

    }
    
    func formatDate(date: Date) -> String {
        dateFormatter.dateFormat = "YY/MM/dd"
        let date = dateFormatter.string(from: key.expirationDate!)
        return date
    }
}


struct QRView: UIViewRepresentable {
    var logo: UIImage?
    var url: String?
    var size: CGSize?
    
    func updateUIView(_ uiView: UIImageView, context: Context) {
        
    }
    
    init(logo: UIImage? = nil, url: String, size: CGSize) {
        self.logo = logo
        self.url = url
        self.size = size
    }

    func makeUIView(context: Context) -> UIImageView {
        return UIImageView.init(image: QRCodeDataSet(logo: logo ?? nil, url: url!, backgroundColor: CIColor(color: .white), color: CIColor(color: .black), size: size!).getQRImage())
    }
}


struct ShareSheet: UIViewControllerRepresentable {

    var items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
         
    }
}

//struct KeysInfoView_Previews: PreviewProvider {
//    static var previews: some View {
//        KeysInfoView(key: LockerKey(keyName: "test", isOneTime: false, expirationDate: Date()))
//    }
//}
