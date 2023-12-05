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
    
    @Binding var showAddMemberPopUp: Bool
    var group: GroupModel
    
    var body: some View {
        Section (header: HStack {
            Text("Add a member")
                .font(.title)
            
            Spacer()
            
            Button(action: {
                showAddMemberPopUp = false
            }) {
                Text("Cancel")
            }
        }) 
        {
            Form {
                Section {
                    Picker("Select a member", selection: $selectedMember) {
                        ForEach(userViewModel.friends, id: \.id) { user in
                            Text(user.fullName).tag(user as User?)
                        }
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
                            if await groupViewModel.memberAlreadyExists(groupId: group.id, userId: selectedUser.id) {
                                existingMember = true
                            } else {
                                addFailed = await !groupViewModel.addMemberIntoGroup(groupId: group.id, userId: selectedUser.id)
                            }
                            showAlert = true
                        }
                    }
                }) {
                    Text("Add member")
                        .foregroundColor(.blue)
                }
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
                            dismissButton: .default(Text("OK"), action: {
                                showAlert = false
                                showAddMemberPopUp = false
                                if let selectedMember = selectedMember {
                                    group.members.append(GroupMember(memberId: selectedMember.id, balance: selectedMember.balance, fullName: selectedMember.fullName))
                                }
                            })
                        )
                    }
                }
            }
        }
        .padding()
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
