//
//  FriendshipModel.swift
//  Debt-Collector
//
//  Created by Amaia Rodriguez-Sierra on 10/11/23.
//

import Foundation

class FriendshipModel: Identifiable, Codable{
    var friend_id: String
    var balance: Int
    
    init(friend_id: String, balance: Int) {
        self.friend_id = friend_id
        self.balance = balance
    }
}
