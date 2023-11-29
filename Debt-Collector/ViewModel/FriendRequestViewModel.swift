//
//  FriendRequestViewModel.swift
//  Debt-Collector
//
//  Created by Martin Sir on 28.11.2023.
//

import Foundation

@MainActor
final class FriendRequestViewModel: ObservableObject {
    @Published private(set) var friendRequests: [FriendRequest] = []
    
    func loadFriendRequests() async {
        if let currentUser = AuthViewModel.shared.currentUser {
            friendRequests = await FriendRequestManager.shared.getFriendRequests(receivedBy: currentUser.id)
        } else {
            print("Error with auth")
        }
    }
}
