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
    var balance: Double {
            calculateBalance()
        }
    
    init(friendId: String, expenses: [ExpenseModel]) {
        self.friendId = friendId
        self.expenses = expenses
    }
    
    func calculateBalance() -> Double {
            expenses.reduce(0.0) { $0 + $1.amount }
        }
}
