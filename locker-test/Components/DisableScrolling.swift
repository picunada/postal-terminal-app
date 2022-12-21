//
//  DisableScrollling.swift
//  locker-test
//
//  Created by Danil Bezuglov on 12/1/22.
//
//
//import Foundation
//import SwiftUI
//
//struct DisableScrolling: ViewModifier {
//    var disabled: Bool
//    
//    func body(content: Content) -> some View {
//    
//        if disabled {
//            content
//                .simultaneousGesture(DragGesture(minimumDistance: 0))
//        } else {
//            content
//        }
//        
//    }
//}
