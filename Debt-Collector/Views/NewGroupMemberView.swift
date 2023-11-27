//
//  NewGroupMemberView.swift
//  Debt-Collector
//
//  Created by user248815 on 11/25/23.
//

import SwiftUI
import FirebaseAuth

struct NewGroupMemberView: View {
    @ObservedObject var viewModel = UserViewModel()
    @State var selectedMember: User?
    
    var group: GroupModel

    var body: some View {
        
        Form {
            Picker("Select a member", selection: $selectedMember) {
                ForEach(viewModel.friends, id: \.id) { user in
                    Text(user.fullName).tag(user as User?)
                }
            }
            .pickerStyle(.menu)
        }
        .task {
            viewModel.getFriends()
        }
        .navigationBarBackButtonHidden(true)

        
 /*       Button(action: {
            if let selectedUser = selectedMember {
                try await viewModel.addGroupMember(groupId: group.id, userId: selectedUser.id, balance: 0)
            } else {
                // Handle the case where selectedMember is nil
                print("No member selected")
            }
        } {
            Text("Add member")
        } */
    }

}
