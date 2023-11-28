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
    func fetchFriendsWithExpenses() async {
            do {
                guard let userId = AuthViewModel.shared.currentUser?.id else { return }
                
                let userFriends = try await UserManager.shared.getAllUserFriends(userId: userId)
                var friendshipModels: [FriendshipModel] = []
                
                for userFriend in userFriends {
                    if let friend = try? await UserManager.shared.getUser(userId: userFriend.friendId) {
                        let expenses = try await GroupManager.shared.getExpenses(groupId: userFriend.friendId)
                        associateExpensesWithFriend(expenses: expenses, friend: friend)
                    }
                }
                
                friendsWithExpenses = friendshipModels
                calculateFriendBalances()
            } catch {
                print("Error fetching friends' expenses: \(error)")
            }
        }
        
    func associateExpensesWithFriend(expenses: [ExpenseModel], friend: User) {
        let friendship = FriendshipModel(friendId: friend.id, expenses: expenses)
        friendsWithExpenses.append(friendship)
    }
        
    func calculateFriendBalances() {
        friendsWithExpenses.forEach { friendModel in
            let totalExpense = friendModel.calculateBalance()
            
        }
    }
    
    func calculateTotalPositiveBalance() -> String {
            let totalPositiveBalance = friendsWithExpenses.filter { $0.balance >= 0 }.reduce(0) { $0 + $1.balance }
            return String(totalPositiveBalance)
        }
        
        func calculateTotalNegativeBalance() -> String {
            let totalNegativeBalance = friendsWithExpenses.filter { $0.balance < 0 }.reduce(0) { $0 + $1.balance }
            return String(totalNegativeBalance)
        }
}
