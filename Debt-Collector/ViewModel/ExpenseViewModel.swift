//
//  ExpenseViewModel.swift
//  Debt-Collector
//
//  Created by user248815 on 11/27/23.
//

import Foundation

@MainActor
final class ExpenseViewModel: ObservableObject {
    @Published private(set) var expenses: [GroupModel] = []
    func deleteExpense(expenseId: String, groupId: String) async throws {
        let expense = try await ExpenseManager.shared.getExpense(expenseId: expenseId, groupId: groupId)
        let totalParticipants = expense.participants.count
        let impactPerParticipant = expense.amount / Double(totalParticipants)
        for participant in expense.participants {
            try await UserManager.shared.updateFriendBalance(userId: expense.paidBy.id, friendId: participant.userId, amount: -impactPerParticipant)
            try await GroupManager.shared.updateBalance(groupId: groupId, memberId: participant.userId, addAmount: true, amount: impactPerParticipant)
            try await UserManager.shared.updateFriendBalance(userId: participant.userId, friendId: expense.paidBy.id, amount: impactPerParticipant)
            try await GroupManager.shared.updateBalance(groupId: groupId, memberId: expense.paidBy.id, addAmount: false, amount: impactPerParticipant)
        }
        try await ExpenseManager.shared.deleteExpenseFromFirebase(expenseId: expenseId, groupId: groupId)
        await fetchDataAndWriteToFile()
    }
    func addExpense(name: String, amount: Double, category: Category?, currency: String, groupId: String, paidBy: User, participants: [Participant], dateCreated: Date) async throws {
        try await ExpenseManager.shared.uploadExpense(name: name, amount: amount, category: category, currency: currency, groupId: groupId, paidBy: paidBy, participants: participants, dateCreated: dateCreated)
        
        // update balances
        for participant in participants {
            try await GroupManager.shared.updateBalance(groupId: groupId, memberId: participant.userId, addAmount: false, amount: participant.amountToPay)
        }
        // add balance to the payer
        try await GroupManager.shared.updateBalance(groupId: groupId, memberId: paidBy.id, addAmount: true, amount: amount)
    }
    
    func editExpense(previousExpense: ExpenseModel, expenseId: String, name: String, amount: Double, category: Category?, currency: String, groupId: String, paidBy: User, participants: [Participant], dateCreated: Date) async throws {
        try await ExpenseManager.shared.updateExpense(expenseId: expenseId, name: name, amount: amount, category: category, currency: currency, groupId: groupId, paidBy: paidBy, participants: participants, dateCreated: dateCreated)
        
        // REVERT - update balances
        for participant in previousExpense.participants {
            try await GroupManager.shared.updateBalance(groupId: previousExpense.groupId, memberId: participant.userId, addAmount: true, amount: participant.amountToPay)
        }
        // REVERT - add balance to the payer
        try await GroupManager.shared.updateBalance(groupId: previousExpense.groupId, memberId: previousExpense.paidBy.id, addAmount: false, amount: previousExpense.amount)
        
        // update balances
        for participant in participants {
            try await GroupManager.shared.updateBalance(groupId: groupId, memberId: participant.userId, addAmount: false, amount: participant.amountToPay)
        }
        // add balance to the payer
        try await GroupManager.shared.updateBalance(groupId: groupId, memberId: paidBy.id, addAmount: true, amount: amount)
    }
}
