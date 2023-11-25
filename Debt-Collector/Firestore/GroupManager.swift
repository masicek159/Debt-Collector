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
    
    func uploadGroup(name: String, currency: String, image: Data?) async throws {
        if let currentUser = await AuthViewModel.shared.currentUser {
            let groupRef = groupCollection.document()
            let group = GroupModel(id: groupRef.documentID, name: name, currency: currency, image: image, owner: currentUser)
            try groupRef.setData(from: group, merge: false)
            let userId = Auth.auth().currentUser?.uid ?? ""
            try await UserManager.shared.addGroupUser(userId: userId, groupId: groupRef.documentID)
        }
    }
    
    func getGroup(groupId: String) async throws -> GroupModel {
        try await groupDocument(groupId: groupId).getDocument(as: GroupModel.self)
    }
    
    func addUserGroup(groupId: String, userId: String, balance: Double) async throws {
        let document = groupMembersCollection(groupId: groupId).document()
        
        let data: [String : Any] = [
            UserGroup.CodingKeys.userId.rawValue : userId,
            UserGroup.CodingKeys.balance.rawValue : balance
        ]
        
        try await document.setData(data, merge: false)
    }
    
    func getAllUserInGroup(groupId: String) async throws -> [UserGroup]{
        try await groupMembersCollection(groupId: groupId).getDocuments(as: UserGroup.self)
    }
    
    func getMembers(groupId: String) async throws -> [User] {
        try await groupMembersCollection(groupId: groupId).getDocuments(as: User.self)
    }
    
    func getExpenses(groupId: String) async throws -> [ExpenseModel] {
        try await groupExpenseCollection(groupId: groupId).getDocuments(as: ExpenseModel.self)
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

struct UserGroup: Codable {
    let userId: String
    let balance: Int

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case balance = "balance"
    }
}
