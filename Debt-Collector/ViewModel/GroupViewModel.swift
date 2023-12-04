//
//  GroupViewModel.swift
//  Debt-Collector
//
//  Created by user248815 on 11/27/23.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
@MainActor
final class GroupViewModel: ObservableObject {
    @Published private(set) var groups: [GroupModel] = []
    @Published private(set) var members: [GroupMember] = []
    private let groupCollection = Firestore.firestore().collection("groups")

   private func groupDocument(groupId: String) -> DocumentReference {
       groupCollection.document(groupId)
   }
    private func getMembersIds(groupId: String) async throws -> [String] {
        var members = try await GroupManager.shared.getMembers(groupId: groupId)
        return members.map { $0.memberId }
    }
    
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
        try await UserManager.shared.addGroupUser(userId: userId, groupId: groupId)
        await fetchDataAndWriteToFile()
    }
    
    func memberAlreadyExists(groupId: String, userId: String) async -> Bool {
        do {
            if try await GroupManager.shared.getMember(groupId: groupId, memberId: userId).exists {
             return true
            }
        } catch {
            print("Error fetching member")
            return false
        }
        return false
    }
    
    func addMemberIntoGroup(groupId: String, userId: String) async -> Bool{
        do {
            try await GroupManager.shared.addGroupMember(groupId: groupId, userId: userId, balance: 0)
            await fetchDataAndWriteToFile()
        } catch {
            print("Error adding member")
            return false
        }
        return true
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
    private func groupMembersCollection(groupId: String) -> CollectionReference {
            groupDocument(groupId: groupId).collection("members")
        }
    func getMembers(groupId: String) async throws -> [GroupMember] {
        try await groupMembersCollection(groupId: groupId).getDocuments(as: GroupMember.self)
    }
    
    func getExpenses(groupId: String) async throws -> [ExpenseModel] {
        try await GroupManager.shared.getExpenses(groupId: groupId)
    }
}
