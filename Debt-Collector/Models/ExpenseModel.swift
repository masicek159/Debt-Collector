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
    var category: Category?
    var currency: String
    var groupId: String
    var paidBy: User
    var participants: [User]

    init(id: String, name: String, amount: Double, category: Category?, currency: String, groupId: String, paidBy: User, participants: [User]) {
        self.id = id
        self.name = name
        self.amount = amount
        self.currency = currency
        self.category = category
        self.groupId = groupId
        self.paidBy = paidBy
        self.participants = participants
    }
    func getExpenseID() -> String {
        return id
    }
    func setExpenseID(newID: String) {
        id = newID
    }
    func getExpenseName() -> String {
        return name
    }
    func setExpenseName(newName: String) {
        name = newName
    }
    func getExpenseAmount() -> Double {
        return amount
    }
    func setExpenseAmount(newAmount: Double) {
        amount = newAmount
    }
    func getExpenseCategory() -> Category? {
        return category
    }
    func setExpenseCategory(newCategory: Category?) {
        category = newCategory
    }
    func getExpenseGroupId() -> String {
        return groupId
    }

    func setExpenseGroupId(newGroupId: String) {
        groupId = newGroupId
    }
    func getExpensePaidBy() -> User {
        return paidBy
    }
    func setExpensePaidBy(newPaidBy: User) {
        paidBy = newPaidBy
    }
    func getExpenseParticipants() -> [User] {
        return participants
    }
    func setExpenseParticipants(newParticipants: [User]) {
        participants = newParticipants
    }
    static func == (lhs: ExpenseModel, rhs: ExpenseModel) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

