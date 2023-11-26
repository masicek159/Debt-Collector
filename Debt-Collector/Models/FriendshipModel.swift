//
//  FriendshipModel.swift
//  Debt-Collector
//
//  Created by Amaia Rodriguez-Sierra on 10/11/23.
//

import Foundation

class FriendshipModel: Identifiable, Codable {
    var friendId: String
    var balance: Int
    
    init(friendId: String, balance: Int) {
        self.friendId = friendId
        self.balance = balance
    }
}
