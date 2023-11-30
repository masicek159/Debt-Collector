//
//  FriendshipModel.swift
//  Debt-Collector
//
//  Created by Amaia Rodriguez-Sierra on 10/11/23.
//

import Foundation

class FriendshipModel: Identifiable, Codable {
    var friendId: String
    var expenses: [ExpenseModel]
    var balance: Double
    
    enum CodingKeys: String, CodingKey {
        case friendId
        case expenses
        case balance
    }
    
    init(friendId: String, expenses: [ExpenseModel], balance: Double) {
        self.friendId = friendId
        self.expenses = expenses
        self.balance = balance
    }
}
