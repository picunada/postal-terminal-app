//
//  ProfileView.swift
//  locker-test
//
//  Created by Danil Bezuglov on 10/17/22.
//

import SwiftUI

struct ProfileView: View {
    var body: some View {
        NavigationView {
            ZStack {
                Text("Hello, world!")
                    .toolbar {
                        ToolbarItemGroup(placement: .principal) {
                            HStack {
                                Text("Home")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                Spacer()
                            }.padding(.top, 90)
                           }
                    }
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
