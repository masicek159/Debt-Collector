//
//  GroupMemberViewModel.swift
//  Debt-Collector
//
//  Created by user248815 on 11/26/23.
//

import Foundation
import FirebaseAuth

@MainActor
final class UserViewModel: ObservableObject {
    @Published var friends: [User] = []
    
    func addGroupMember(groupId: String, userId: String, balance: Double = 0) async throws {
        try await GroupManager.shared.addGroupMember(groupId: groupId, userId: userId, balance: balance)
    }
    
    func getFriends () {
        Task {
            guard let userId = AuthViewModel.shared.currentUser?.id else { return }
            let userFriends = try await UserManager.shared.getAllUserFriends(userId: userId)
            var localArray: [User] = []
            
            for userFriend in userFriends {
                if let friend = try? await UserManager.shared.getUser(userId: userFriend.friendId) {
                    localArray.append(friend)
                }
            }
            self.friends = localArray
        }
    }
    
    func addFriendRequest(email: String) async -> Bool {
        let user: User? = await UserManager.shared.getUser(email: email)
        if let user = user, let currentUser = AuthViewModel.shared.currentUser {
            
            // already friends
            do {
                guard let friend = try await UserManager.shared.getFriend(userId: currentUser.id, friendId: user.id) else {return false}
            } catch {
                print("Error getting friend")
                return false
            }
            // TODO: notify the requested user
            do {
                try await FriendRequestManager.shared.uploadFriendRequest(receiverId: user.id, senderId: currentUser.id)
            } catch {
                print("Error creating friend request")
                return false
            }
            return true
        } else {
            return false
        }
    }
    
    func addFriend(userId: String, friendId: String) async throws {
        //let friend: User? = try await UserManager.shared.getUser(userId: friendId)
           
        try await UserManager.shared.addFriendToUser(userId: userId, friendId: friendId, balance: 0)
    }
}
