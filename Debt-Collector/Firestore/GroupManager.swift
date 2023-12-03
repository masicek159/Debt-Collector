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
    
    func uploadGroup(name: String, currency: String, color: Data) async throws {
        if let currentUser = await AuthViewModel.shared.currentUser {
            let groupRef = groupCollection.document()
            let group = GroupModel(id: groupRef.documentID, name: name, currency: currency, color: color.base64EncodedString(), owner: currentUser)
            try groupRef.setData(from: group, merge: false)
            let userId = Auth.auth().currentUser?.uid ?? ""
            try await UserManager.shared.addGroupUser(userId: userId, groupId: groupRef.documentID)
            try await addGroupMember(groupId: group.id, userId: currentUser.id, balance: 0)
        }
    }
    
    func deleteGroup(groupId: String) {
        groupDocument(groupId: groupId).delete { error in
            if let error = error {
                print("Error deleting document: \(error)")
            } else {
                print("Document successfully deleted!")
            }
        }
    }
        
    func getGroup(groupId: String) async throws -> GroupModel {
        try await groupDocument(groupId: groupId).getDocument(as: GroupModel.self)
    }
    
    func addGroupMember(groupId: String, userId: String, balance: Double) async throws {
        let document = groupMembersCollection(groupId: groupId).document()
        
        let data: [String : Any] = [
            GroupMember.CodingKeys.memberId.rawValue : userId,
            GroupMember.CodingKeys.balance.rawValue : balance
        ]
        
        try await document.setData(data, merge: false)
    }
    
    func getMembers(groupId: String) async throws -> [GroupMember]{
        try await groupMembersCollection(groupId: groupId).getDocuments(as: GroupMember.self)
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
