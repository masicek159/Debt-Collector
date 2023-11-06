//
//  NewGroupView.swift
//  Debt-Collector
//
//  Created by Martin Sir on 05.11.2023.
//

import SwiftUI

struct NewGroupView: View {
    @ObservedObject var viewModel: GroupsViewModel
    @Binding var showPopup: Bool
    
    @State private var groupName = ""
        @State private var groupCurrency = ""
        @State private var groupImage = ""
    
    var body: some View {
        Form {
            Section(header: Text("Group Information")) {
                  TextField("Name", text: $groupName)
                  TextField("Currency", text: $groupCurrency)
              }
              
            Section(header: Text("Group Image")) {
                  TextField("Image URL", text: $groupImage)
              }
              
            Button(action: {
                  Task {
                      try await viewModel.addGroup(name: groupName, currency: groupCurrency, image: groupImage)
                      showPopup = false
                      viewModel.getGroups()
                  }
              }) {
                  Text("Create Group")
              }
          }
          .navigationBarTitle("Create Group")
      }
}

struct NewGroupView_Previews: PreviewProvider {
    static var previews: some View {
    NewGroupView(viewModel: GroupsViewModel(), showPopup: .constant(false))
    }
}
