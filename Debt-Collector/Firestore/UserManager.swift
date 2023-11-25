//
//  UserManager.swift
//  Debt-Collector
//
//  Created by Martin Sir on 04.11.2023.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth

final class UserManager {
    static let shared = UserManager()
    private init () {}
    
    private let userCollection: CollectionReference = Firestore.firestore().collection("users")
    
    private func groupUserCollection(userId: String) -> CollectionReference {
        userDocument(userId: userId).collection("groups")
    }
    
    private func groupUserDocument(userId: String, groupId: String) -> DocumentReference {
        groupUserCollection(userId: userId).document(groupId)
    }
    
    private func userDocument(userId: String) -> DocumentReference {
        userCollection.document(userId)
    }
    
    func createFirestoreUserIfNotExists(uid: String, email: String, fullName: String) async {
        let userRef = Firestore.firestore().collection("users").document(uid)
        let userDoc = try? await userRef.getDocument()
        if let document = userDoc, document.exists {
            return
        } else {
            let user = User(id: uid, email: email, fullName: fullName)
            guard let encodedUser = try? Firestore.Encoder().encode(user) else { return }
            try? await userRef.setData(encodedUser)
        }
    }
    
    func fetchFirestoreUser() async -> User? {
        guard let uid = Auth.auth().currentUser?.uid else { return nil }
        guard let snapshot = try? await Firestore.firestore().collection("users").document(uid).getDocument() else { return nil }
        return try? snapshot.data(as: User.self)
    }
    
    func addGroupUser(userId: String, groupId: String, role: String = "member") async throws {
        let document = groupUserCollection(userId: userId).document()
        
        let data: [String : Any] = [
            GroupUser.CodingKeys.dateCreated.rawValue : Timestamp(),
            GroupUser.CodingKeys.role.rawValue : role,
            GroupUser.CodingKeys.groupId.rawValue : groupId,
        ]
        
        try await document.setData(data, merge: false)
    }
        
    func getAllUserFriends(userId: String) async throws -> [FriendshipModel] {
        let user = try await userDocument(userId: userId).getDocument(as: User.self)
        return user.friends
    }
    
    func getAllUserGroups(userId: String) async throws -> [GroupUser] {
        try await groupUserCollection(userId: userId).getDocuments(as: GroupUser.self)
    }
    
    func getUser(userId: String) async throws -> User {
        try await userDocument(userId: userId).getDocument(as: User.self)
    }
}

struct GroupUser: Codable {
    let dateCreated: Date
    let role: String
    let groupId: String
    
    enum CodingKeys: String, CodingKey {
        case dateCreated = "date_created"
        case role = "role"
        case groupId = "group_id"
    }
    
}
