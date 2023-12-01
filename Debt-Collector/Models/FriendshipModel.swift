//
//  FriendshipModel.swift
//  Debt-Collector
//
//  Created by Amaia Rodriguez-Sierra on 10/11/23.
//

import Foundation

class FriendshipModel: Identifiable, Codable {
    var friendId: String
    var balance: Double
    
    enum CodingKeys: String, CodingKey {
        case friendId = "friendId"
        case balance = "balance"
    }
    
    init(friendId: String, balance: Double) {
        self.friendId = friendId
        self.balance = balance
    }
}
