//
//  GroupDetail.swift
//  Debt-Collector
//
//  Created by Martin Sir on 09.11.2023.
//

import SwiftUI
import FirebaseAuth

@MainActor
final class GroupMemberViewModel: ObservableObject {
    @Published private(set) var friends: [User] = []
    
    func addGroupMember(groupId: String, userId: String, balance: Double = 0) async throws {
        try await GroupManager.shared.addUserGroup(groupId: groupId, userId: userId, balance: balance)
    }
    
    func getFriends () {
        Task {
            guard let userId = Auth.auth().currentUser?.uid else { return }
            let userFriends = try await UserManager.shared.getAllUserFriends(userId: userId)
            
            var localArray: [User] = []
            
            for userFriend in userFriends {
                if let friend = try? await UserManager.shared.getUser(userId: userFriend.friendId) {
                    localArray.append(friend)
                }
            }
            self.friends = localArray
        }
    }
    
}

struct GroupDetail: View {
    @ObservedObject var groupsViewModel = GroupsViewModel()
    @ObservedObject var groupMemberViewModel = GroupMemberViewModel()
    
    var group: GroupModel
    @State var expenses: [ExpenseModel] = []
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    HStack {
                        if let imageData = group.image, let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 72, height: 72)
                        } else {
                            // TODO: tmp obrazek postavy
                            Image(systemName: "person.3")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 72, height: 72)
                        }
                        
                        Spacer()
                        
                        VStack {
                            Text(group.name)
                            
                            Text(group.currency)
                                .font(.footnote)
                                .foregroundColor(.gray)
                        }
                    }
                    
                }
                
                Section("Members") {
                    NavigationLink(destination: NewGroupMemberView(viewModel: groupMemberViewModel)) {
                        Text("Add Member")
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                }
                
                Section("Expenses") {
                    ForEach(expenses, id: \.id) { expense in
                        HStack{
                            Text(expense.name)
                            
                            Text("\(expense.amount)")
                        }
                    }
                }
            }
        }
        .onAppear {
            Task {
                expenses = try await groupsViewModel.getExpenses(groupId: group.id)
            }
        }
    }
}

struct GroupDetail_Previews: PreviewProvider {
    static var previews: some View {
        GroupDetail(group: GroupModel(id: "1", name: "Group name", currency: "USD", image: nil, owner: User(id: "ss", email: "Friend1@gmail.com", fullName: "Friend 1")))
    }
}

