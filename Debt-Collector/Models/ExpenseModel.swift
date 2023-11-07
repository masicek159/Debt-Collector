//
//  ExpenseModel.swift
//  Debt-Collector
//
//  Created by Amaia Rodriguez-Sierra on 9/11/23.
//

import Foundation

class ExpenseModel: Identifiable, Codable {
    var id: String
    var name: String
    var amount: Double
    var category: String
    var group: String
    var paidBy: User
    var participants: [User]

    init(id: String, name: String, amount: Double, category: String, group: String, paidBy: User, participants: [User]) {
        self.id = id
        self.name = name
        self.amount = amount
        self.category = category
        self.group = group
        self.paidBy = paidBy
        self.participants = participants
    }
    
    static func == (lhs: ExpenseModel, rhs: ExpenseModel) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

