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
            var allRequests = await FriendRequestManager.shared.getFriendRequests(receivedBy: currentUser.id)
            friendRequests = allRequests.filter{ $0.status == "PENDING"}
        } else {
            print("Error with auth")
        }
    }
    
    func updateRequestStatus(updatedStatus: String, requestId: String) {
        FriendRequestManager.shared.updateRequestStatus(updatedStatus: updatedStatus, requestId: requestId)
    }
}
