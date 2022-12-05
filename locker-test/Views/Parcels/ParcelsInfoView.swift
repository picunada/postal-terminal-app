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
                VStack(alignment: .center) {
                    VStack(alignment: .leading) {
                        HStack(alignment: .center) {
                            Image(systemName: "shippingbox")
                                .resizable()
                                .frame(width: 25, height: 25)
                                .padding()
                                .foregroundColor(Color(UIColor.systemIndigo))
                                .background(Color(UIColor.systemBackground))
                                .clipShape(Circle())
                            VStack(alignment: .leading) {
                                Text("\(status.capitalized) parcel")
                                    .font(.title3)
                                    .fontWeight(.medium)
                                    .padding(.bottom, 1)
                                Text("Status: \(status)")
                                    .font(.callout)
                                    .foregroundColor(Color(uiColor: .secondaryLabel))
                                if receivedDate != nil {
                                    Text(formatDate(date: receivedDate!))
                                        .font(.callout)
                                        .foregroundColor(Color(uiColor: .secondaryLabel))
                                }
                            }
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
                            .padding(.vertical)
                            HStack {
                                Text("Track & Trace")
                                Spacer()
                                Text(parcel.trackingNumber)
                                    .foregroundColor(Color(uiColor: .secondaryLabel))
                            }
                            .padding(.vertical)
                            HStack {
                                Text("Receiver")
                                Spacer()
                                Text("\(user.firstName.capitalized) \(user.lastName.capitalized)")
                                    .foregroundColor(Color(uiColor: .secondaryLabel))
                            }
                            .padding(.vertical)
                            HStack {
                                Text("Estimated delivery date ")
                                Spacer()
                                Text("\(formatDateMonth(date: parcel.estimatedDeliveryDate.lowerBound)) - \(formatDateMonth(date: parcel.estimatedDeliveryDate.upperBound))")
                                    .foregroundColor(Color(uiColor: .secondaryLabel))
                            }
                            .padding(.vertical)
                            
                        }
                        .scrollContentBackground(.hidden)
                        .padding(.top, 0)
                    } else {
                        List {
                            HStack {
                                Text("Delivery service")
                                Spacer()
                                Text(parcel.serviceName)
                                    .foregroundColor(Color(uiColor: .secondaryLabel))
                            }
                            .padding(.vertical)
                            HStack {
                                Text("Track & Trace")
                                Spacer()
                                Text(parcel.trackingNumber)
                                    .foregroundColor(Color(uiColor: .secondaryLabel))
                            }
                            .padding(.vertical)
                            HStack {
                                Text("Receiver")
                                Spacer()
                                Text("\(user.firstName.capitalized) \(user.lastName.capitalized)")
                                    .foregroundColor(Color(uiColor: .secondaryLabel))
                            }
                            .padding(.vertical)
                            HStack {
                                Text("Estimated delivery date ")
                                Spacer()
                                Text("\(formatDateMonth(date: parcel.estimatedDeliveryDate.lowerBound)) - \(formatDateMonth(date: parcel.estimatedDeliveryDate.upperBound))")
                                    .foregroundColor(Color(uiColor: .secondaryLabel))
                            }
                            .padding(.vertical)
                            
                        }
                        .onAppear {
                            UITableView.appearance().backgroundColor = .clear
                        }
                        .padding(.top, 0)
                    }
                    Button {
                        parcelState.deleteParcel(parcel: parcel, user: authState.lockerUser!, type: status.lowercased())
                    } label: {
                        VStack {
                            HStack(alignment: .firstTextBaseline) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                                Text("Delete parcel")
                                    .font(.title3)
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                    .tint(.clear)
                    .padding()
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
