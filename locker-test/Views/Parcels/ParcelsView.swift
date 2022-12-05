//
//  ParcelsView.swift
//  locker-test
//
//  Created by Danil Bezuglov on 10/15/22.
//

import SwiftUI
import CodeScanner

struct ParcelsView: View {
    @Environment(\.defaultMinListRowHeight) var minRowHeight
    
    @EnvironmentObject var authState: AuthViewModel
    @ObservedObject var parcelState: ParcelViewModel
    
    let deliveryServices = ["DHL", "EMS", "Shopee Xpress", "LEX VN", "FedEx", "Standart Express", "Aliepress Standart"]
    
    @State var showCreateParcel: Bool = false
    @State var newParcel: Parcel = Parcel(serviceName: "DHL", trackingNumber: "", estimatedDeliveryDate: Date()...Date())
    
    @State var selectedDate: Date = Date()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(uiColor: .secondarySystemBackground).ignoresSafeArea()
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
                    .padding(.top, -8)
                
                    ParcelListView(expectedParcels: parcelState.expectedParcels, receivedParcels: parcelState.receivedParcels, parcelState: parcelState)
                }
                .padding(.horizontal)
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .accentColor(.primary)
    }
    
    var createParcel: some View {
        NavigationView {
            VStack {
                TextField("Tracking number", text: $newParcel.trackingNumber)
                    .modifier(QrButton(text: $newParcel.trackingNumber))
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground).cornerRadius(8))
                    .autocapitalization(.none)
                if #available(iOS 16.0, *) {
                    Form {
                        Section {
                            Picker("Select delivery service", selection: $newParcel.serviceName) {
                                ForEach(deliveryServices , id: \.self) {
                                    Text($0)
                                }
                            }
                            .foregroundColor(Color(UIColor.secondaryLabel))
                            DatePicker("Select delivery date", selection: $selectedDate , in: Date()..., displayedComponents: .date)
                                .padding(.top)
                                .foregroundColor(Color(UIColor.secondaryLabel))
                                .accentColor(.indigo)
                                .pickerStyle(.menu)
                        }
                        
                    }
                    .scrollContentBackground(.hidden)
                    .listStyle(.inset)
                    .padding(.horizontal, -20)
                    .padding(.top, -20)
                    .background(Color(UIColor.white))
                } else {
                    // Fallback on earlier versions
                    Form {
                        Section {
                            Picker("Select delivery service", selection: $newParcel.serviceName) {
                                ForEach(deliveryServices , id: \.self) {
                                    Text($0)
                                }
                            }
                            .foregroundColor(Color(UIColor.secondaryLabel))
                            .background(Color(.secondarySystemBackground))
                            DatePicker("Select delivery date", selection: $selectedDate , in: Date()..., displayedComponents: .date)
                                .padding(.top)
                                .foregroundColor(Color(UIColor.secondaryLabel))
                                .accentColor(.indigo)
                                .pickerStyle(.menu)
                                .background(Color(.secondarySystemBackground))
                        }
                        
                    }
                    .onAppear {
                        UITableView.appearance().backgroundColor = .clear
                    }
                    .listStyle(.inset)
                    .padding(.horizontal, -20)
                    .padding(.top, -20)
                    .background(Color(UIColor.white))
                }
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
        .accentColor(.black)
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
                                    Image(systemName: "shippingbox")
                                        .resizable()
                                        .padding(.all, 5)
                                        .frame(width: 41, height: 41)
                                        .foregroundColor(Color(UIColor.systemIndigo))
                                        .background(Color(UIColor.systemBackground))
                                        .overlay(
                                                    Circle()
                                                        .stroke(Color.indigo, lineWidth: 1)
                                                )
                                        .clipShape(Circle())
                                    VStack(alignment: .leading) {
                                        Text(parcel.serviceName)
                                            .font(.callout)
                                        Text(parcel.trackingNumber)
                                            .font(.callout)
                                            .foregroundColor(Color(UIColor.secondaryLabel))
                                    }
                                }
                                .padding(.vertical, 10)
                            }
                        }
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
                                            .frame(width: 41, height: 41)
                                            .foregroundColor(Color(UIColor.systemIndigo))
                                            .background(Color(UIColor.systemBackground))
                                            .overlay(
                                                        Circle()
                                                            .stroke(Color.indigo, lineWidth: 1)
                                                    )
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
                    } header: {
                        Text("RECEIVED")
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .listStyle(.insetGrouped)
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
                        }
                        
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
                        }
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


struct QrButton: ViewModifier
{
    @Binding var text: String
        
    public func body(content: Content) -> some View
    {
        ZStack(alignment: .trailing)
        {
            content
            
            if !text.isEmpty {
                Button(action:
                {
                    self.text = ""
                })
                {
                    Image(systemName: "delete.left")
                        .resizable()
                        .frame(width: 32, height: 26)
                        .foregroundColor(Color(uiColor: .systemIndigo))
                }
                .padding(.trailing, 8)
            } else {
                NavigationLink {
                    ScannerView(text: $text)
                } label: {
                    Image(systemName: "qrcode.viewfinder")
                        .resizable()
                        .frame(width: 26, height: 26)
                        .foregroundColor(Color(uiColor: .systemIndigo))
                }
                .padding(.trailing, 8)
            }
        }
    }
}
