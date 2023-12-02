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
    @Published private(set) var members: [User] = []
    
    func addGroup(name: String, currency: String, color: Data) async throws {
        try await GroupManager.shared.uploadGroup(name: name, currency: currency, color: color)
    }
    
    func deleteGroup(groupId: String) {
        GroupManager.shared.deleteGroup(groupId: groupId)
        if let index = self.groups.firstIndex(where: { $0.id == groupId }) {
            self.groups.remove(at: index)
        }
    }
    
    func addGroupMember(groupId: String, userId: String, balance: Double = 0) async throws {
        try await GroupManager.shared.addGroupMember(groupId: groupId, userId: userId, balance: balance)
    }
    
    func memberAlreadyExists(groupId: String, userId: String) async -> Bool {
        do {
            guard !(try await GroupManager.shared.getMember(groupId: groupId, memberId: userId).exists) else {return false}
        } catch {
            print("Error fetching member")
            return false
        }
        return true
    }
    
    func addMemberIntoGroup(groupId: String, userId: String) async -> Bool{
        do {
            try await GroupManager.shared.addGroupMember(groupId: groupId, userId: userId, balance: 0)
        } catch {
            print("Error adding member")
            return false
        }
        return true
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
    
    func getMembers(groupId: String) {
        Task {
            let groupMembers = try await GroupManager.shared.getMembers(groupId: groupId)
            var localArray: [User] = []
            
            for groupMember in groupMembers {
                if let member = try? await UserManager.shared.getUser(userId: groupMember.memberId) {
                    localArray.append(member)
                }
            }
            
            self.members = localArray
        }
    }
    
    func getExpenses(groupId: String) async throws -> [ExpenseModel] {
        try await GroupManager.shared.getExpenses(groupId: groupId)
    }
}
