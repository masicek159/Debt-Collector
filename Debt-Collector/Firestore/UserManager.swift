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
    func getUsersForGroupMembers(groupMembers: [GroupMember]) async throws -> [User] {
        var users: [User] = []
        
        for groupMember in groupMembers {
            let userId = groupMember.memberId
            do {
                let user = try await getUser(userId: userId)
                users.append(user)
            } catch {
                // Handle the error, e.g., log it or skip the user in case of an error
                print("Error fetching user details for userId \(userId): \(error)")
            }
        }
        
        return users
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
        let document = groupUserCollection(userId: userId).document(groupId)
        
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
    
    func getFriend(userId: String, friendId: String) async throws -> DocumentSnapshot {
        return try await friendsDocument(userId: userId, friendId: friendId).getDocument()
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
        let friendsDoc = friendsCollection(userId: userId).document(friendId)
        
        let data: [String : Any] = [
            FriendshipModel.CodingKeys.friendId.rawValue : friendId,
            FriendshipModel.CodingKeys.balance.rawValue : balance
        ]
        
        try await friendsDoc.setData(data, merge: false)
        
    }
    func updateFriendBalance(userId: String, friendId: String, amount: Double) async throws {
        let userDocument = Firestore.firestore().collection("users").document(userId)
        let friendsCollection = userDocument.collection("friends")

        do {
            // Find the friend document in the subcollection
            let friendDocument = friendsCollection.whereField("friendId", isEqualTo: friendId)
            let friendSnapshot = try await friendDocument.getDocuments()

            // Ensure there's only one document (assuming friendId is unique)
            guard var friendData = friendSnapshot.documents.first?.data() else {
                // Handle the case where the friend is not found
                print("Error: Friend with ID \(friendId) not found in the user's subcollection.")
                return
            }

            // Update the balance
            if var balance = friendData["balance"] as? Double {
                balance -= amount
                friendData["balance"] = balance

                // Update the friend's document in Firebase
                try await friendSnapshot.documents.first?.reference.setData(friendData, merge: true)
            } else {
                // Handle the case where balance is not a valid Double
                print("Error: Invalid balance data for friend with ID \(friendId)")
            }
        } catch {
            // Handle the error
            print("Error updating friend balance: \(error)")
            throw error
        }
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
