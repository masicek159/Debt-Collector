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
        await fetchDataAndWriteToFile()
    }
    
    func deleteGroup(groupId: String) {
        GroupManager.shared.deleteGroup(groupId: groupId)
        if let index = self.groups.firstIndex(where: { $0.id == groupId }) {
            self.groups.remove(at: index)
        }
    }
    
    func addGroupMember(groupId: String, userId: String, balance: Double = 0) async throws {
        try await GroupManager.shared.addGroupMember(groupId: groupId, userId: userId, balance: balance)
        await fetchDataAndWriteToFile()
    }
    
    func getGroupMember(groupId: String, userId: String) async throws -> GroupMember? {
        try await GroupManager.shared.getMember(groupId: groupId, memberId: userId)
    }
    func readGroupFile() throws -> [GroupModel] {
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent("groupFile.json")

        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            let groupModels = try decoder.decode([GroupModel].self, from: data)
            return groupModels
        } catch {
            throw error
        }
    }
    
    func getGroups () {
        Task {
                do {
                    // Read the contents of the groupFile.json file
                    let groupModels = try readGroupFile()

                    // Update the groups array
                    self.groups = groupModels
                } catch {
                    print("Error reading group file: \(error)")
                }
            }
    }
    
    func getMembers(groupId: String) {
        Task {
                do {
                    // Read the contents of the groupFile.json file
                    let groupModels = try readGroupFile()

                    // Find the group with the specified groupId
                    if let targetGroup = groupModels.first(where: { $0.id == groupId }) {
                        // Update the members array with the members of the target group
                        self.members = targetGroup.members
                    } else {
                        print("Group with ID \(groupId) not found in groupFile.json")
                    }
                } catch {
                    print("Error reading group file: \(error)")
                }
            }
    }
    
    func getExpenses(groupId: String) async throws -> [ExpenseModel] {
        try await GroupManager.shared.getExpenses(groupId: groupId)
    }
}
