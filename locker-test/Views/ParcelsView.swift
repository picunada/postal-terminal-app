//
//  ParcelsView.swift
//  locker-test
//
//  Created by Danil Bezuglov on 10/15/22.
//

import SwiftUI

struct ParcelsView: View {
    @Environment(\.defaultMinListRowHeight) var minRowHeight
    
    @EnvironmentObject var authState: AuthViewModel
    @ObservedObject var parcelState: ParcelViewModel
    
    let deliveryServices = ["DHL", "EMS", "Shopee Xpress", "LEX VN", "FedEx", "Standart Express", "Aliepress Standart"]
    
    @State var showCreateParcel: Bool = false
    @State var newParcel: Parcel = Parcel(serviceName: "DHL", trackingNumber: "", estimatedDeliveryDate: Date()...Date())
    
    @State var selectedDate: Date = Date()
    
    var body: some View {
        ZStack {

            VStack(alignment: .leading) {
                HStack {
                    Text("Parcels")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Spacer()
                    Button {
                        showCreateParcel.toggle()
                        print("Button clicked")
                    } label: {
                        Image(systemName: "plus")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .padding()
                            .foregroundColor(Color.white)
                            .background(Color(UIColor.systemIndigo))
                            .clipShape(Circle())
                    }
                    .sheet(isPresented: $showCreateParcel) {
                        createParcel
                    }

                }
                .padding(.top, 40)
                .padding(.horizontal)
            
                ParcelListView(expectedParcels: parcelState.expectedParcels, receivedParcels: parcelState.receivedParcels, parcelState: parcelState)
            }
        }
    }
    
    var createParcel: some View {
        NavigationView {
            ScrollView {
                VStack {
                    TextField("Tracking number", text: $newParcel.trackingNumber)
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground).cornerRadius(8))
                        .autocapitalization(.none)
                    List {
                        Picker("Select delivery service", selection: $newParcel.serviceName) {
                            ForEach(deliveryServices , id: \.self) { service in
                                Text(service)
                            }
                        }
                        .foregroundColor(Color(UIColor.secondaryLabel))
                        DatePicker("Estimated delivery date", selection: $selectedDate , in: Date()..., displayedComponents: .date)
                            .padding(.top)
                            .foregroundColor(Color(UIColor.secondaryLabel))
                    }
                    .frame(maxWidth: .infinity, minHeight: minRowHeight * 3)
                    .listStyle(.inset)
                    .padding(/*@START_MENU_TOKEN@*/.top/*@END_MENU_TOKEN@*/)
                    .background(Color(UIColor.white))
                    VStack {
                        Button {
                            newParcel.estimatedDeliveryDate = selectedDate...Calendar.current.date(byAdding: .day, value: 2, to: selectedDate)!
                            parcelState.createParcel(parcel: newParcel, user: authState.lockerUser!)
                            showCreateParcel.toggle()
                        } label: {
                            Text("Save")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(Color.white)
                                .frame(maxWidth: .infinity)
                        }
                        .padding()
                        .background(Color(UIColor.secondaryLabel).cornerRadius(8))
                        .accessibilityLabel("Save new parcel")
                    }
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Create parcel")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                                    Button {
                                        showCreateParcel.toggle()
                                    } label: {
                                        Image(systemName: "multiply")
                                            .foregroundColor(.black)
                                    }
                                }
                            }
        }
    }
}

struct ParcelListView: View {
    
    var expectedParcels: [Parcel]
    var receivedParcels: [Parcel]
    
    @ObservedObject var parcelState: ParcelViewModel
    @EnvironmentObject var authState: AuthViewModel
    
    init(expectedParcels: [Parcel], receivedParcels: [Parcel], parcelState: ParcelViewModel) {
        self.expectedParcels = expectedParcels
        self.receivedParcels = receivedParcels
        self.parcelState = parcelState
    }
    
    
    var body: some View {
        if #available(iOS 16.0, *) {
            List {
                if expectedParcels.count != 0 {
                    Section {
                        ForEach(expectedParcels, id: \.id) { parcel in
                            NavigationLink {
                                ParcelsInfoView(parcelState: parcelState, parcel: parcel, user: authState.lockerUser!, status: "Expected")
                            } label: {
                                HStack {
                                    VStack {
                                        Image(systemName: "shippingbox")
                                            .resizable()
                                            .frame(width: 25, height: 25)
                                            .padding()
                                            .foregroundColor(Color(UIColor.systemIndigo))
                                            .background(Color(UIColor.secondarySystemBackground))
                                            .clipShape(Circle())
                                    }
                                    VStack(alignment: .leading) {
                                        Text(parcel.serviceName)
                                            .font(.callout)
                                        Text(parcel.trackingNumber)
                                            .font(.callout)
                                            .foregroundColor(Color(UIColor.secondaryLabel))
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }
                        .listRowBackground(Color(uiColor: .secondarySystemBackground))
                    } header: {
                        Text("EXPECTED")
                    }
                }
                if receivedParcels.count != 0 {
                    Section {
                        ForEach(receivedParcels, id: \.id) { parcel in
                            NavigationLink {
                                ParcelsInfoView(parcelState: parcelState, parcel: parcel, user: authState.lockerUser!, status: "Received")
                            } label: {
                                HStack {
                                    VStack {
                                        Image(systemName: "shippingbox")
                                            .resizable()
                                            .frame(width: 25, height: 25)
                                            .padding()
                                            .foregroundColor(Color(UIColor.white))
                                            .background(Color(UIColor.systemBackground))
                                            .clipShape(Circle())
                                    }
                                    VStack(alignment: .leading) {
                                        Text(parcel.serviceName)
                                            .font(.callout)
                                        Text(parcel.trackingNumber)
                                            .font(.callout)
                                            .foregroundColor(Color(UIColor.secondaryLabel))
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }.listRowBackground(Color(uiColor: .secondarySystemBackground))
                    } header: {
                        Text("RECEIVED")
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .listStyle(.automatic)
            .padding(.horizontal, -20)
        } else {
            List {
                if expectedParcels.count != 0 {
                    Section {
                        ForEach(expectedParcels, id: \.id) { parcel in
                            NavigationLink {
                                ParcelsInfoView(parcelState: parcelState, parcel: parcel, user: authState.lockerUser!, status: "Expected")
                            } label: {
                                HStack {
                                    VStack {
                                        Image(systemName: "shippingbox")
                                            .resizable()
                                            .frame(width: 25, height: 25)
                                            .padding()
                                            .foregroundColor(Color(UIColor.systemIndigo))
                                            .background(Color(UIColor.systemBackground))
                                            .clipShape(Circle())
                                    }
                                    VStack(alignment: .leading) {
                                        Text(parcel.serviceName)
                                            .font(.callout)
                                        Text(parcel.trackingNumber)
                                            .font(.callout)
                                            .foregroundColor(Color(UIColor.secondaryLabel))
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }.listRowBackground(Color(uiColor: .secondarySystemBackground))
                        
                    } header: {
                        Text("EXPECTED")
                    }
                }
                if receivedParcels.count != 0 {
                    Section {
                        ForEach(receivedParcels, id: \.id) { parcel in
                            NavigationLink {
                                ParcelsInfoView(parcelState: parcelState, parcel: parcel, user: authState.lockerUser!, status: "Received")
                            } label: {
                                HStack {
                                    VStack {
                                        Image(systemName: "shippingbox")
                                            .resizable()
                                            .frame(width: 25, height: 25)
                                            .padding()
                                            .foregroundColor(Color(UIColor.white))
                                            .background(Color(UIColor.systemBackground))
                                            .clipShape(Circle())
                                    }
                                    VStack(alignment: .leading) {
                                        Text(parcel.serviceName)
                                            .font(.callout)
                                        Text(parcel.trackingNumber)
                                            .font(.callout)
                                            .foregroundColor(Color(UIColor.secondaryLabel))
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }.listRowBackground(Color(uiColor: .secondarySystemBackground))
                    } header: {
                        Text("RECEIVED")
                    }
                }
            }
            .onAppear(perform: {
                        UITableView.appearance().backgroundColor = UIColor.clear
                    })
            .listStyle(.automatic)
            .padding(.horizontal, -20)
        }
        
    }
}
