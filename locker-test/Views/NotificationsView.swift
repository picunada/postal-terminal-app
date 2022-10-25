//
//  NotificationsView.swift
//  locker-test
//
//  Created by Danil Bezuglov on 10/17/22.
//

import SwiftUI

struct NotificationsView: View {
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

struct NotificationsView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationsView()
    }
}
