//
//  NewGroupView.swift
//  Debt-Collector
//
//  Created by Martin Sir on 05.11.2023.
//

import SwiftUI
import PhotosUI

struct NewGroupView: View {
    @ObservedObject var viewModel: GroupsViewModel
    @EnvironmentObject var currenciesHelper: CurrenciesHelper
    @Binding var showPopup: Bool
    @State var uploadingGroup = false
    
    @State private var groupName = ""
    @State private var groupCurrency = ""
    @State private var groupImage = ""
    
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil
    
    var body: some View {
        Form {
            Section(header: Text("Group Information")) {
                TextField("Name", text: $groupName)
                
                Picker("Select Currency", selection: $groupCurrency) {
                    ForEach(currenciesHelper.currencies, id: \.self) { currency in
                        Text(currency)
                    }
                }
                .pickerStyle(.menu)
            }
            
            Section(header: Text("Group Image")) {
                PhotosPicker(
                           selection: $selectedItem,
                           matching: .images,
                           photoLibrary: .shared()) {
                               Text("Select a photo")
                           }
                           .onChange(of: selectedItem) { newItem in
                               Task {
                                   // Retrieve selected asset in the form of Data
                                   if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                       selectedImageData = data
                                   }
                               }
                           }
                       
                       if let selectedImageData,
                          let uiImage = UIImage(data: selectedImageData) {
                           HStack {
                               Spacer()
                               Image(uiImage: uiImage)
                                   .resizable()
                                   .scaledToFit()
                                   .frame(width: 250, height: 250)
                               Spacer()
                           }
                       }
            }
            
            Button(action: {
                Task {
                    uploadingGroup = true
                    try await viewModel.addGroup(name: groupName, currency: groupCurrency, image: selectedImageData)
                    showPopup = false
                    viewModel.getGroups()
                }
            }) {
                Text("Create Group")
            }
        }
        .disabled(uploadingGroup)
        .navigationBarTitle("Create Group")
        .task {
            groupCurrency = currenciesHelper.currencies.first ?? ""
        }
    }
}

struct NewGroupView_Previews: PreviewProvider {
    static var previews: some View {
    NewGroupView(viewModel: GroupsViewModel(), showPopup: .constant(false))
    }
}
