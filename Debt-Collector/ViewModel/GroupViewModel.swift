//
//  GroupViewModel.swift
//  Debt-Collector
//
//  Created by user248815 on 11/27/23.
//

import Foundation
import FirebaseAuth

@MainActor
final class GroupViewModel: ObservableObject {
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
    
    func getMembers(groupId: String) async throws -> [GroupMember] {
        try await GroupManager.shared.getMembers(groupId: groupId)
    }
    
    func getExpenses(groupId: String) async throws -> [ExpenseModel] {
        try await GroupManager.shared.getExpenses(groupId: groupId)
    }
}
