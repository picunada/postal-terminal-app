//
//  LoadingView.swift
//  locker-test
//
//  Created by Danil Bezuglov on 10/26/22.
//

import SwiftUI

struct LoadingView: View {
    @State private var isLoading = false
    
    var body: some View {
        VStack(alignment: .center) {
            Image(systemName: "rays")
                .resizable()
                .frame(width: 50, height: 50)
                .foregroundColor(.indigo)
                .rotationEffect(Angle(degrees: isLoading ? 360 : 0))
                .animation(Animation.linear(duration: 3).repeatForever(autoreverses: false), value: isLoading)
                .onAppear() {
                                self.isLoading = true
                            }
        }
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
    }
}
