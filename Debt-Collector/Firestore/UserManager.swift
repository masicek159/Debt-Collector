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
    
    private func friendsCollection(userId: String) -> CollectionReference {
        userDocument(userId: userId).collection("friends")
    }
    
    private func friendsDocument(userId: String, friendId: String) -> DocumentReference {
        friendsCollection(userId: userId).document(friendId)
    }
    
    private func userDocument(userId: String) -> DocumentReference {
        userCollection.document(userId)
    }
    
    private func userDocument(forEmail email: String) async throws -> DocumentReference? {
        let querySnapshot = try await userCollection.whereField("email", isEqualTo: email).getDocuments()
        
        if let document = querySnapshot.documents.first {
            return document.reference
        } else {
            return nil
        }
    }
    
    func getUser(email: String) async -> User? {
        do {
            let userRef = try await userDocument(forEmail: email)
            if let userRef = userRef {
                let documentSnapshot = try await userRef.getDocument()
                return try documentSnapshot.data(as: User.self)
            } else {
                return nil
            }
        } catch {
            print("Error: \(error)")
            return nil
        }
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
        try await friendsCollection(userId: userId).getDocuments(as: FriendshipModel.self)
    }
    
    func getFriend(userId: String, friendId: String) async throws -> FriendshipModel? {
        try await friendsDocument(userId: userId, friendId: friendId).getDocument(as: FriendshipModel.self)
    }
    
    func getAllUserGroups(userId: String) async throws -> [GroupUser] {
        try await groupUserCollection(userId: userId).getDocuments(as: GroupUser.self)
    }
    
    func getUser(userId: String) async throws -> User {
        try await userDocument(userId: userId).getDocument(as: User.self)
    }
    
    func getUsers(userIds: [String]) async throws -> [User] {
        if userIds.isEmpty {
            return []
        } else {
            return try await userCollection.whereField(FieldPath.documentID(), in: userIds).getDocuments(as: User.self)
        }
    }
    
    func addFriendToUser(userId: String, friendId: String, balance: Double) async throws {
        let friendsDoc = friendsCollection(userId: userId).document()
            
        let data: [String : Any] = [
            FriendshipModel.CodingKeys.friendId.rawValue : friendId,
            FriendshipModel.CodingKeys.balance.rawValue : balance
        ]
            
        try await friendsDoc.setData(data, merge: false)
        
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
