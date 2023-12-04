//
//  UserViewModel.swift
//  Debt-Collector
//
//  Created by user248815 on 11/26/23.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

@MainActor
final class UserViewModel: ObservableObject {
    @Published var friends: [User] = []
    @Published var friendsWithExpenses: [FriendshipModel] = []
    @Published var positiveBalance: String = ""
    @Published var negativeBalance: String = ""
    
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
                guard !(try await UserManager.shared.getFriend(userId: currentUser.id, friendId: user.id).exists) else {
                    print("Already have this friend")
                    return false
                }
            } catch {
                print("Error getting friend: \(error)")
                return false
            }
            
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
                        let friendship = FriendshipModel(friendId: friend.id, balance: totalExpense)
                        updatedFriendships.append(friendship)
                    }
                }
                print(updatedFriendships[0].balance, updatedFriendships[1].balance)
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
    
    func fetchPositiveBalances(completion: @escaping (Float) -> Void) {
        if let userId = Auth.auth().currentUser?.uid {
            Firestore.firestore().collection("users").document(userId).collection("friends")
                .whereField("balance", isGreaterThanOrEqualTo: 0)
                .getDocuments { snapshot, error in
                    guard let snapshot = snapshot, error == nil else {
                        print("Error fetching positive balances: \(error?.localizedDescription ?? "Unknown error")")
                        completion(0.0)
                        return
                    }
                    
                    let positiveBalance = snapshot.documents.reduce(0.0) { $0 + ($1["balance"] as? Double ?? 0.0) }
                    completion(Float(positiveBalance))
                }
        }
    }

        func fetchNegativeBalances(completion: @escaping (Float) -> Void) {
            if let userId = Auth.auth().currentUser?.uid {
                Firestore.firestore().collection("users").document(userId).collection("friends")
                    .whereField("balance", isLessThan: 0)
                    .getDocuments { snapshot, error in
                        guard let snapshot = snapshot, error == nil else {
                            print("Error fetching negative balances: \(error?.localizedDescription ?? "Unknown error")")
                            completion(0.0)
                            return
                        }
                        
                        let negativeBalance = snapshot.documents.reduce(0.0) { $0 + ($1["balance"] as? Double ?? 0.0) }
                        completion(Float(negativeBalance))
                    }
            }
        }
    
    func fetchBalances() {
            fetchPositiveBalances { positiveBalance in
                self.positiveBalance = String(positiveBalance)
            }

            fetchNegativeBalances { negativeBalance in
                self.negativeBalance = String(negativeBalance)
            }
        self.negativeBalance = self.negativeBalance
    }
}
