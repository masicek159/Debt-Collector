//
//  GroupManager.swift
//  Debt-Collector
//
//  Created by Martin Sir on 04.11.2023.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth

final class GroupManager {
    
    static let shared = GroupManager()
    private init () {}
    
    private let groupCollection = Firestore.firestore().collection("groups")
    
    private func groupDocument(groupId: String) -> DocumentReference {
        groupCollection.document(groupId)
    }
    
    private func groupMembersCollection(groupId: String) -> CollectionReference {
        groupDocument(groupId: groupId).collection("members")
    }
    
    private func groupMemberDocument(memberId: String, groupId: String) -> DocumentReference {
        groupMembersCollection(groupId: groupId).document(memberId)
    }
    
    private func groupExpenseCollection(groupId: String) -> CollectionReference {
        groupDocument(groupId: groupId).collection("expenses")
    }
    
    private func groupExpenseDocument(expenseId: String, groupId: String) -> DocumentReference {
        groupMembersCollection(groupId: groupId).document(expenseId)
    }
    
    func deleteMember(groupId: String, userId: String) throws {
        let groupMembersCollection = groupDocument(groupId: groupId).collection("members")
        let memberDocument = groupMembersCollection.document(userId)

        do {
            // Delete the member document
            try memberDocument.delete()
        } catch {
            // Handle the error
            print("Error deleting group member: \(error)")
            throw error
        }
    }
    
    func uploadGroup(name: String, currency: String, color: Data) async throws {
        if let currentUser = await AuthViewModel.shared.currentUser {
            let groupRef = groupCollection.document()
            let group = GroupModel(id: groupRef.documentID, name: name, currency: currency, color: color.base64EncodedString(), owner: currentUser)
            try groupRef.setData(from: group, merge: false)
            try await UserManager.shared.addGroupUser(userId: currentUser.id, groupId: groupRef.documentID)
            try await addGroupMember(groupId: group.id, userId: currentUser.id, balance: 0)
        }
    }
    
    func deleteGroupInUsers(groupId: String) {
        Firestore.firestore().collectionGroup("groups")
            .whereField("group_id", isEqualTo: groupId)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error getting documents to delete: \(error)")
                } else {
                    for document in querySnapshot!.documents {
                        // Delete each document
                        document.reference.delete { deleteError in
                            if let deleteError = deleteError {
                                print("Error deleting document: \(deleteError)")
                            } else {
                                print("Document successfully deleted")
                            }
                        }
                    }
                }
            }
    }
    
    func deleteGroup(groupId: String) {
        groupDocument(groupId: groupId).delete { error in
            if let error = error {
                print("Error deleting document: \(error)")
            } else {
                print("Document successfully deleted!")
                self.deleteGroupInUsers(groupId: groupId)
            }
        }
    }
        
    func getGroup(groupId: String) async throws -> GroupModel {
        try await groupDocument(groupId: groupId).getDocument(as: GroupModel.self)
    }
    
    func addGroupMember(groupId: String, userId: String, balance: Double) async throws {
        let document = groupMembersCollection(groupId: groupId).document(userId)
        
        let data: [String : Any] = [
            GroupMember.CodingKeys.memberId.rawValue : userId,
            GroupMember.CodingKeys.balance.rawValue : balance
        ]
        
        try await document.setData(data, merge: false)
    }
    
    func getMembers(groupId: String) async throws -> [GroupMember]{
        try await groupMembersCollection(groupId: groupId).getDocuments(as: GroupMember.self)
    }

    func updateBalance(groupId: String, memberId: String, addAmount: Bool, amount: Double) async throws {
        let member = groupMemberDocument(memberId: memberId, groupId: groupId)
        var newAmount: Double = try await member.getDocument(as: GroupMember.self).balance
        if addAmount {
            newAmount += amount
        } else {
            newAmount -= amount
        }
        try await member.updateData(["balance": newAmount])
    }
    
    func getMember(groupId: String, memberId: String) async throws -> DocumentSnapshot {
        return try await groupMemberDocument(memberId: memberId, groupId: groupId).getDocument()
    }
    
    func getExpenses(groupId: String) async throws -> [ExpenseModel] {
        try await groupExpenseCollection(groupId: groupId).getDocuments(as: ExpenseModel.self)
    }
    
    func getExpensesInvolvingFriend(userId: String, friendId: String) async throws -> [ExpenseModel] {
        let expenses = try await groupExpenseCollection(groupId: userId).getDocuments(as: ExpenseModel.self)
        let expensesInvolvingFriend = expenses.filter { expense in
            let participantsIds = expense.participants.map { $0.userId }
            return participantsIds.contains(userId) && participantsIds.contains(friendId)
        }
        return expensesInvolvingFriend
    }
}

extension Query {
    func getDocuments<T>(as type: T.Type) async throws -> [T] where T : Decodable {
        let snapshot = try await self.getDocuments()
        return try snapshot.documents.map({ document in
            try document.data(as: T.self)
        })
    }
}
