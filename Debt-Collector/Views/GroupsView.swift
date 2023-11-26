//
//  GroupsView.swift
//  Debt-Collector
//
//  Created by user248815 on 10/19/23.
//

import SwiftUI
import FirebaseAuth

@MainActor
final class GroupsViewModel: ObservableObject {
    @Published private(set) var groups: [GroupModel] = []
    
    func addGroup(name: String, currency: String, image: Data?) async throws {
        try await GroupManager.shared.uploadGroup(name: name, currency: currency, image: image)
    }
    
    func getGroups () {
        Task {
            guard let userId = Auth.auth().currentUser?.uid else { return }
            let userGroups = try await UserManager.shared.getAllUserGroups(userId: userId)
            
            var localArray: [GroupModel] = []
            
            for userGroup in userGroups {
                if let group = try? await GroupManager.shared.getGroup(groupId: userGroup.groupId) {
                    localArray.append( group)
                }
            }
            self.groups = localArray
        }
    }
    
    func getMembers(groupId: String) async throws -> [User] {
        try await GroupManager.shared.getMembers(groupId: groupId)
    }
    
    func getExpenses(groupId: String) async throws -> [ExpenseModel] {
        try await GroupManager.shared.getExpenses(groupId: groupId)
    }
}

struct GroupsView: View {
    @ObservedObject var groupViewModel = GroupsViewModel()
    @State private var showPopup = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(groupViewModel.groups, id: \.id) { group in
                    NavigationLink(destination: GroupDetail(group: group)) {
                        HStack {
                            Text(group.name)
                        }
                    }
                }
            }
            .navigationTitle("My Groups")
            .navigationBarItems(trailing: Button(action: {
                showPopup.toggle()
            }, label: {
                Image(systemName: "plus")
            }))
            .sheet(isPresented: $showPopup, content: {
                NewGroupView(viewModel: groupViewModel, showPopup: $showPopup)
            })
            .task {
                groupViewModel.getGroups()
            }
        }
    }
}
