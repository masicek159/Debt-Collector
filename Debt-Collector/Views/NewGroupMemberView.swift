//
//  NewGroupMemberView.swift
//  Debt-Collector
//
//  Created by user248815 on 11/25/23.
//

import SwiftUI
import FirebaseAuth

struct NewGroupMemberView: View {
    @ObservedObject var userViewModel = UserViewModel()
    @ObservedObject var groupViewModel = GroupViewModel()
    @State var selectedMember: User?
    @State private var addFailed: Bool = false
    @State private var showAlert: Bool = false
    @State private var existingMember: Bool = false
    
    var group: GroupModel

    func memberAlreadyExists(groupId: String, userId: String, groupViewModel: GroupViewModel) async -> Bool {
        do {
            guard (try await groupViewModel.getGroupMember(groupId: groupId, userId: userId)) != nil else {return false}
        } catch {
            print("Error fetching member")
            return false
        }
        return true
    }
    
    func addMemberIntoGroup(groupId: String, userId: String, groupViewModel: GroupViewModel) async -> Bool{
        do {
            try await groupViewModel.addGroupMember(groupId: groupId, userId: userId)
        } catch {
            print("Error adding member")
            return false
        }
        return true
    }
    
    var body: some View {
        Form {
            Section {
                Picker("Select a member", selection: $selectedMember) {
                    ForEach(userViewModel.friends, id: \.id) { user in
                        Text(user.fullName).tag(user as User?)
                    }
                }
                .pickerStyle(.menu)
            }
            .task {
                userViewModel.getFriends()
            }
            .navigationBarBackButtonHidden(true)
        
            // accept request
            Section {
                Button(action: {
                    // add friend
                    Task {
                        if let selectedUser = selectedMember {
                            if await !memberAlreadyExists(groupId: group.id, userId: selectedUser.id, groupViewModel: groupViewModel) {
                                existingMember = true
                            } else {
                                addFailed = await !addMemberIntoGroup(groupId: group.id, userId: selectedUser.id, groupViewModel: groupViewModel)
                            }
                            showAlert = true
                        }
                    }
                }) {
                    Text("Add member")
                        .foregroundColor(.blue)
                }
                //        .disabled(!isFormValid)
                .alert(isPresented: $showAlert) {
                    if existingMember {
                        return Alert(
                            title: Text("Warning"),
                            message: Text("This user is already member of the group!"),
                            dismissButton: .default(Text("OK"), action: {
                                showAlert = false
                            })
                        )
                    }
                    else if addFailed {
                        return Alert(
                            title: Text("Warning"),
                            message: Text("Failed to add member!"),
                            dismissButton: .default(Text("OK"), action: {
                                showAlert = false
                            })
                        )
                    } else {
                        return Alert(
                            title: Text("Success"),
                            message: Text("Member added successfully!"),
                            dismissButton: .default(Text("Cancel"), action: {
                                showAlert = false
                            })
                        )
                    }
                }
            }
        }
    }
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
