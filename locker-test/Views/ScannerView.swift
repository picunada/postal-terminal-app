//
//  ScannerView.swift
//  locker-test
//
//  Created by Danil Bezuglov on 10/26/22.
//

import SwiftUI
import CodeScanner

struct ScannerView: View {
    
    @Binding var text: String
    
    var body: some View {
        NavigationView {
            ZStack {
                CodeScannerView(codeTypes: [.qr]) { response in
                    switch response {
                    case .success(let result):
                        text = result.string
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
                ZStack {
                    Rectangle()
                        .opacity(0.3)
                        .ignoresSafeArea()
                    
                    VStack(alignment: .center) {
                        RoundedRectangle(cornerRadius: 30)
                            .frame(width: 310, height: 310)
                            .background(Color(uiColor: .clear))
                            .blendMode(.destinationOut)
                            .overlay {
                                RoundedRectangle(cornerRadius: 30)
                                    .stroke(.white, style: StrokeStyle(lineWidth: 5, dash: [148], dashPhase: 220))
                            }
                        Text("Point your camera to the Tracking number")
                            .padding()
                            .background(Color(uiColor: .white).opacity(0.6))
                            .cornerRadius(12)
                            .padding(.top, 100)
                    }
                    
                }
                .compositingGroup()
                
            }
        }
        .accentColor(.black)
    }
}

//struct ScannerView_Previews: PreviewProvider {
//    static var previews: some View {
//        ScannerView()
//    }
//}
