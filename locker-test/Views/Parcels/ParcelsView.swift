//
//  ParcelsView.swift
//  locker-test
//
//  Created by Danil Bezuglov on 10/15/22.
//

import SwiftUI
import CodeScanner
import FirebaseStorage

struct ParcelsView: View {
    @Environment(\.defaultMinListRowHeight) var minRowHeight
    
    @EnvironmentObject var authState: AuthViewModel
    @ObservedObject var parcelState: ParcelViewModel
    @StateObject var serviceVM: ServicesViewModel = .init()
    
//    let deliveryServices = ["DHL", "EMS", "Shopee Xpress", "LEX VN", "FedEx", "Standart Express", "Aliepress Standart"]
    
    @State var showCreateParcel: Bool = false
    @State var newParcel: Parcel = Parcel(serviceName: "DHL", trackingNumber: "", estimatedDeliveryDate: Date()...Date())
    @State private var calendarId: Int = 0
    @State var selectedDate: Date = Date()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(uiColor: .secondarySystemBackground).ignoresSafeArea()
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Text("Parcels")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Spacer()
                        VStack {
                            Button {
                                showCreateParcel.toggle()
                            } label: {
                                Image(systemName: "plus")
                                    .resizable()
                                    .padding()
                                    .foregroundColor(Color.white)
                            }
                            .sheet(isPresented: $showCreateParcel) {
                                createParcel
                            }
                        }
                        .frame(width: 55, height: 55)
                        .background(Color("AccentColor"))
                        .clipShape(Circle())
                        
                    }
                    .padding(.top, 40)
                    .padding(.bottom, 50)
                    
                    if (parcelState.expectedParcels.isEmpty && parcelState.receivedParcels.isEmpty) {
                        EmptyParcelsView()
                    } else {
                        ParcelListView(expectedParcels: parcelState.expectedParcels, receivedParcels: parcelState.receivedParcels, parcelState: parcelState, serviceVM: serviceVM)
                    }
                }
                .padding(.horizontal)
            }
            .navigationBarTitle("")
            .navigationBarHidden(true)
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            serviceVM.fetchServices()
        }
        .accentColor(.primary)
    }
    
    var createParcel: some View {
        NavigationView {
            ScrollView {
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
                                    ForEach(serviceVM.services , id: \.id) { service in
                                        Text(service.name)
                                            .tag(service.name)
                                    }
                                }
                                .foregroundColor(Color(UIColor.secondaryLabel))
                                .padding(.bottom)
                                DatePicker("Select delivery date", selection: $selectedDate , in: Date()..., displayedComponents: .date)
                                    .id(calendarId)
                                    .onChange(of: selectedDate, perform: { _ in
                                      calendarId += 1
                                    })
                                    .onTapGesture {
                                      calendarId += 1
                                    }
                                    .padding(.top)
                                    .padding(.bottom)
                                    .foregroundColor(Color(UIColor.secondaryLabel))
                                    .accentColor(.indigo)
                                    .pickerStyle(.menu)
                            }
                            .listRowInsets(EdgeInsets())
                        }
                        .scrollDisabled(true)
                        .frame(height: 150)
                        .scrollContentBackground(.hidden)
                        .listStyle(.inset)
                        .padding(.top, -20)
                        .background(Color(UIColor.white))
                    } else {
                        // Fallback on earlier versions
                        Form {
                            Section {
                                Picker("Select delivery service", selection: $newParcel.serviceName) {
                                    ForEach(serviceVM.services , id: \.self) {
                                        Text($0.name)
                                    }
                                }
                                .foregroundColor(Color(UIColor.secondaryLabel))
                                DatePicker("Select delivery date", selection: $selectedDate , in: Date()..., displayedComponents: .date)
                                    .id(calendarId)
                                    .onChange(of: selectedDate, perform: { _ in
                                      calendarId += 1
                                    })
                                    .onTapGesture {
                                      calendarId += 1
                                    }
                                    .padding(.top)
                                    .padding(.bottom)
                                    .foregroundColor(Color(UIColor.secondaryLabel))
                                    .accentColor(.indigo)
                                    .pickerStyle(.menu)
                            }
                            .listRowInsets(EdgeInsets())
                        }
                        .frame(height: 150)
                        .onAppear {
                            UITableView.appearance().backgroundColor = .clear
                            UITableView.appearance().isScrollEnabled = false
                        }
                        .listStyle(.inset)
                        .padding(.top, -20)
                        .background(Color(UIColor.white))
                        
                    }
                    
                    Spacer()
                    
                    VStack {
                        Button {
                            newParcel.estimatedDeliveryDate = selectedDate...Calendar.current.date(byAdding: .day, value: 2, to: selectedDate)!
                            parcelState.createParcel(parcel: newParcel, user: authState.lockerUser!)
                            newParcel = Parcel(serviceName: "DHL", trackingNumber: "", estimatedDeliveryDate: Date()...Date())
                            showCreateParcel.toggle()
                        } label: {
                            Text("Save")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(Color.white)
                                .frame(maxWidth: .infinity)
                        }
                        .frame(height: 48)
                        .padding(.horizontal)
                        .background(newParcel.trackingNumber.isEmpty ? .secondary : Color("AccentColor"))
                        .cornerRadius(8)
                        .accessibilityLabel("Save new parcel")
                        .disabled(newParcel.trackingNumber.isEmpty)
                    }
                    .padding(.top, 235)
                }
//                .animation(.default, value: newParcel.trackingNumber.isEmpty)
                .padding()
                .padding(.bottom, 93)
                .padding(.top, 40)
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle("Add a new parcel")
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
}

struct ParcelListView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    var expectedParcels: [Parcel]
    var receivedParcels: [Parcel]
    
    @ObservedObject var parcelState: ParcelViewModel
    @EnvironmentObject var authState: AuthViewModel
    @ObservedObject var serviceVM: ServicesViewModel
    
    init(expectedParcels: [Parcel], receivedParcels: [Parcel], parcelState: ParcelViewModel, serviceVM: ServicesViewModel) {
        self.expectedParcels = expectedParcels
        self.receivedParcels = receivedParcels
        self.parcelState = parcelState
        self.serviceVM = serviceVM
    }
    
    
    var body: some View {
        
        if #available(iOS 16.0, *) {
            List {
                if expectedParcels.count != 0 {
                    Section {
                        ForEach(expectedParcels, id: \.id) { parcel in
                            ParcelItem(parcelState: parcelState, serviceVM: serviceVM, parcel: parcel, status: "active")
                        }
                    } header: {
                        Text("EXPECTED")
                    }
                }
                if receivedParcels.count != 0 {
                    Section {
                        ForEach(receivedParcels, id: \.id) { parcel in
                            ParcelItem(parcelState: parcelState, serviceVM: serviceVM, parcel: parcel, status: "inactive")
                        }
                    } header: {
                        Text("RECEIVED")
                    }
                }
            }
            .onAppear {
                serviceVM.fetchServices()
            }
            .scrollContentBackground(.hidden)
            .listStyle(InsetGroupedListStyle())
            .padding(.horizontal, -20)
        } else {
            List {
                if expectedParcels.count != 0 {
                    Section {
                        ForEach(expectedParcels, id: \.id) { parcel in
                            ParcelItem(parcelState: parcelState, serviceVM: serviceVM, parcel: parcel, status: "active")
                        }
                        
                    } header: {
                        Text("EXPECTED")
                    }
                }
                if receivedParcels.count != 0 {
                    Section {
                        ForEach(receivedParcels, id: \.id) { parcel in
                            ParcelItem(parcelState: parcelState, serviceVM: serviceVM, parcel: parcel, status: "inactive")
                        }
                    } header: {
                        Text("RECEIVED")
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .onAppear(perform: {
                UITableView.appearance().backgroundColor = UIColor.clear
                    })
            .listStyle(.automatic)
            .padding(.horizontal, -20)
        }
        
    }
}

// MARK: Empty view

struct EmptyParcelsView: View {
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Image("EmptyParcels")
                .padding(.top, 109)
            Text("There are no expected packages yet.\n You can add a parcel by clicking on the\n button above.")
                .bold()
                .multilineTextAlignment(.center) 
                .font(.custom("empty parcels", size: 17))
                .padding(.top, 40)
            Spacer()
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity)
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
            } else {
                NavigationLink {
                    ScannerView(text: $text)
                } label: {
                    Image(systemName: "qrcode.viewfinder")
                        .resizable()
                        .frame(width: 26, height: 26)
                        .foregroundColor(Color(uiColor: .systemIndigo))
                }
            }
        }
    }
}

struct ParcelItem: View {
    
    @EnvironmentObject var authState: AuthViewModel
    @ObservedObject var parcelState: ParcelViewModel
    @ObservedObject var serviceVM: ServicesViewModel
    var parcel: Parcel
    var status: String
    
    @State var image: UIImage?
    
    var body: some View {
        NavigationLink {
            ParcelsInfoView(parcelState: parcelState, serviceVM: serviceVM, image: image, parcel: parcel, user: authState.lockerUser ?? LockerUser(firstName: "", lastName: ""), status: status)
        } label: {
            HStack {
                VStack {
                    if let service = serviceVM.services.first(where: { service in
                        return service.name == parcel.serviceName
                    }) {
                        
                        
                        if image != nil {
                            Image(uiImage: image!)
                                .resizable()
                                .clipShape(Circle())
                                .frame(width: 41, height: 41)
                                .padding()
                                .saturation(status == "active" ? 1 : 0)
                                
                        } else {
                            Image(systemName: "shippingbox")
                                .resizable()
                                .frame(width: 25, height: 25)
                                .saturation(status == "active" ? 1 : 0)
                                .padding()
                                .foregroundColor(Color("AccentColor"))
                                .onAppear {
                                    let storageRef = Storage.storage().reference()
                                    let fileRef = storageRef.child(service.imageURL)
                                    
                                    fileRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
                                      if let error = error {
                                          print(error)
                                      } else {
                                           image = UIImage(data: data!)
                                      }
                                    }
                                }
                        }
                    }
                }
                .frame(width: 41, height: 41)
                .overlay(Circle().stroke(.secondary, lineWidth: 1))
                
                VStack(alignment: .leading, spacing: 5) {
                    Text(parcel.serviceName)
                    Text(parcel.trackingNumber)
                        .foregroundColor(Color(UIColor.secondaryLabel))
                }
                .padding(.leading)
            }
            .animation(.default, value: image)
        }
        .listRowInsets(EdgeInsets())
        .padding()
    }
}
