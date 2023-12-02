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
    @Published var friendsWithExpenses: [FriendshipModel] = []
    
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
                guard (try await UserManager.shared.getFriend(userId: currentUser.id, friendId: user.id)) != nil else {return false}
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
    
    func fetchFriendsWithExpenses() async {
            guard let currentUser = AuthViewModel.shared.currentUser else { return }
            
            do {
                let userFriends = try await UserManager.shared.getAllUserFriends(userId: currentUser.id)
                var updatedFriendships: [FriendshipModel] = []

                for userFriend in userFriends {
                    if let friend = try? await UserManager.shared.getUser(userId: userFriend.friendId) {
                        let expenses = try await GroupManager.shared.getExpensesInvolvingFriend(userId: currentUser.id, friendId: userFriend.friendId)
                        let totalExpense = expenses.reduce(0.0) { $0 + $1.amount }
                        let friendship = FriendshipModel(friendId: friend.id, expenses: expenses, balance: totalExpense)
                        updatedFriendships.append(friendship)
                    }
                }
                self.friendsWithExpenses = updatedFriendships
            } catch {
                print("Error fetching friends' expenses: \(error)")
            }
        }
    
    func calculateTotalPositiveBalance() -> String {
            let totalPositiveBalance = friendsWithExpenses.filter { $0.balance >= 0 }.reduce(0.0) { $0 + $1.balance }
            return String(format: "%.2f", totalPositiveBalance)
        }
        
    func calculateTotalNegativeBalance() -> String {
        let totalNegativeBalance = friendsWithExpenses.filter { $0.balance < 0 }.reduce(0.0) { $0 + $1.balance }
        return String(format: "%.2f", totalNegativeBalance)
    }
}
