//
//  FriendRequestManager.swift
//  Debt-Collector
//
//  Created by Martin Sir on 28.11.2023.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth

final class FriendRequestManager {
    
    static let shared = FriendRequestManager()
    private init () {}
    
    private let friendRequestCollection = Firestore.firestore().collection("friendRequests")
    
    private func friendRequestDocument(friendRequestId: String) -> DocumentReference {
        friendRequestCollection.document(friendRequestId)
    }
    
    func uploadFriendRequest(receiverId: String, senderId: String) async throws {
        // TODO: check if there is already existing request / if so update sent date
        let friendRequest = FriendRequest(read: false, receiverId: receiverId, senderId: senderId, sentDate: Timestamp(date: Date()))
        try friendRequestCollection.document().setData(from: friendRequest, merge: false)
    }
    
    func getFriendRequest(friendRequestId: String) async throws -> FriendRequest {
        try await friendRequestDocument(friendRequestId: friendRequestId).getDocument(as: FriendRequest.self)
    }
    
    func getFriendRequests(receivedBy receiverId: String) async -> [FriendRequest] {
        do {
            let friendRequests = try await friendRequestCollection.whereField("receiverId", isEqualTo: receiverId).getDocuments(as: FriendRequest.self)
            let userIdsToLoad = friendRequests.map { $0.senderId }
            let users = try await UserManager.shared.getUsers(userIds: userIdsToLoad)
            let nameDictionary = Dictionary(uniqueKeysWithValues: users.map { ($0.id, ($0.fullName, $0.email)) })
            for friendRequest in friendRequests {
                friendRequest.senderFullName = nameDictionary[friendRequest.senderId]?.0 ?? ""
                friendRequest.senderEmail = nameDictionary[friendRequest.senderId]?.1 ?? ""
            }
            return friendRequests
        } catch {
            print("Problem fetching friend requests")
            return []
        }
    }
}
