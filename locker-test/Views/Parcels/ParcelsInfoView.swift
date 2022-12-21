//
//  ParcelsInfoView.swift
//  locker-test
//
//  Created by Danil Bezuglov on 10/17/22.
//

import SwiftUI

struct ParcelsInfoView: View {
    
    @ObservedObject var parcelState: ParcelViewModel
    @EnvironmentObject var authState: AuthViewModel
    
    var parcel: Parcel
    var user: LockerUser
    var status: String
    var receivedDate: Date?
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(uiColor: .secondarySystemBackground).ignoresSafeArea()
                VStack(alignment: .center, spacing: 0) {
                    VStack(alignment: .leading, spacing: 0) {
                        HStack(alignment: .center) {
                            VStack {
                                Image(systemName: "shippingbox")
                                    .resizable()
                                    .frame(width: 25, height: 25)
                                    .padding()
                                    .foregroundColor(Color(UIColor.systemIndigo))
                            }
                            .frame(width: 41, height: 41)
                            .overlay(Circle().stroke(.secondary, lineWidth: 1))
                            
                            VStack(alignment: .leading, spacing: 10) {
                                Text("\(status.capitalized) parcel")
                                    .bold()
                                Text("Status: \(status)")
                                    .foregroundColor(Color(uiColor: .secondaryLabel))
                                if receivedDate != nil {
                                    Text(formatDate(date: receivedDate!))
                                        .font(.callout)
                                        .foregroundColor(Color(uiColor: .secondaryLabel))
                                }
                            }
                            .padding(.leading, 24)
                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity)
                    if #available(iOS 16.0, *) {
                        List {
                            HStack {
                                Text("Delivery service")
                                Spacer()
                                Text(parcel.serviceName)
                                    .foregroundColor(Color(uiColor: .secondaryLabel))
                            }
                            .listRowInsets(EdgeInsets())
                            .padding(.horizontal)
                            .padding(.vertical, 19)
                            HStack {
                                Text("Track & Trace")
                                Spacer()
                                Text(parcel.trackingNumber)
                                    .foregroundColor(Color(uiColor: .secondaryLabel))
                            }
                            .listRowInsets(EdgeInsets())
                            .padding(.horizontal)
                            .padding(.vertical, 19)
                            HStack {
                                Text("Receiver")
                                Spacer()
                                Text("\(user.firstName.capitalized) \(user.lastName.capitalized)")
                                    .foregroundColor(Color(uiColor: .secondaryLabel))
                            }
                            .listRowInsets(EdgeInsets())
                            .padding(.horizontal)
                            .padding(.vertical, 19)
                            HStack(alignment: .top, spacing: 0) {
                                Text("Estimated delivery date ")
                                    .frame(width: 155, alignment: .leading)
                                    .multilineTextAlignment(.leading)
                                Spacer()
                                Text("\(formatDateMonth(date: parcel.estimatedDeliveryDate.lowerBound)) - \(formatDateMonth(date: parcel.estimatedDeliveryDate.upperBound))")
                                    .foregroundColor(Color(uiColor: .secondaryLabel))
                            }
                            .listRowInsets(EdgeInsets())
                            .padding(.horizontal)
                            .padding(.vertical, 19)
                        }
                        .frame(height: 300)
                        .scrollContentBackground(.hidden)
                    } else {
                        List {
                            HStack {
                                Text("Delivery service")
                                Spacer()
                                Text(parcel.serviceName)
                                    .foregroundColor(Color(uiColor: .secondaryLabel))
                            }
                            .listRowInsets(EdgeInsets())
                            .padding(.horizontal)
                            .padding(.vertical, 19)
                            HStack {
                                Text("Track & Trace")
                                Spacer()
                                Text(parcel.trackingNumber)
                                    .foregroundColor(Color(uiColor: .secondaryLabel))
                            }
                            .listRowInsets(EdgeInsets())
                            .padding(.horizontal)
                            .padding(.vertical, 19)
                            HStack {
                                Text("Receiver")
                                Spacer()
                                Text("\(user.firstName.capitalized) \(user.lastName.capitalized)")
                                    .foregroundColor(Color(uiColor: .secondaryLabel))
                            }
                            .listRowInsets(EdgeInsets())
                            .padding(.horizontal)
                            .padding(.vertical, 19)
                            HStack(alignment: .top, spacing: 0) {
                                VStack {
                                    Text("Estimated delivery\n date ")
                                        .multilineTextAlignment(.leading)
                                }
                                .frame(width: 155, alignment: .leading)
                                Spacer()
                                Text("\(formatDateMonth(date: parcel.estimatedDeliveryDate.lowerBound)) - \(formatDateMonth(date: parcel.estimatedDeliveryDate.upperBound))")
                                    .foregroundColor(Color(uiColor: .secondaryLabel))
                            }
                            .listRowInsets(EdgeInsets())
                            .padding(.horizontal)
                            .padding(.vertical, 19)
                        }
                        .frame(height: 300)
                        .onAppear {
                            UITableView.appearance().backgroundColor = .clear
                        }
                    }
                    Spacer()
                    Button {
                        parcelState.deleteParcel(parcel: parcel, user: authState.lockerUser!, type: status.lowercased())
                    } label: {
                        HStack(alignment: .center, spacing: 10) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                            Text("Delete parcel")
                                .font(.title3)
                                .foregroundColor(.primary)
                        }
                    }
                    .tint(.clear)
                    .padding()
                    .padding(.bottom, 49)
                    .accessibilityLabel("Delete parcel")
                }
                .padding(.bottom)
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

func formatDate(date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .long
    dateFormatter.timeStyle = .short
    
    return dateFormatter.string(from: date)
}

func formatDateMonth(date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MMM d"
    
    return dateFormatter.string(from: date)
}

//struct ParcelsInfoView_Previews: PreviewProvider {
//    static var previews: some View {
//        ParcelsInfoView(parcel: Parcel(serviceName: "DHL", trackingNumber: "5674234009548293", estimatedDeliveryDate: Date()...Date()), user: LockerUser(firstName: "Daniil", lastName: "Bezuglov", lockerId: "1231asdceraszxcv"), status: "Received", receivedDate: Date())
//    }
//}
