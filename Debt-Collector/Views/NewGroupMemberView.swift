//
//  NewGroupMemberView.swift
//  Debt-Collector
//
//  Created by user248815 on 11/25/23.
//

import SwiftUI
import FirebaseAuth

struct NewGroupMemberView: View {
    @ObservedObject var viewModel: GroupMemberViewModel
    
    var currentUserId: String? = Auth.auth().currentUser?.uid
    @State var selectedMember: User?
    
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
            print(viewModel.friends)
        }
        
        
        
        
        
        
        //        Task{
        //            viewModel.addGroupMember(groupId:group.id, userId:balance:)
        
    }
}
