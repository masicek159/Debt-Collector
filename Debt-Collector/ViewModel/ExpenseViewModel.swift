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
    
    func addExpense(name: String, amount: Double, category: String, currency: String, groupId: String, paidBy: User, participants: [Participant]) async throws {
        try await ExpenseManager.shared.uploadExpense(name: name, amount: amount, category: category, currency: currency, groupId: groupId, paidBy: paidBy, participants: participants)
        
        // update balances
        for participant in participants {
            try await GroupManager.shared.updateBalance(groupId: groupId, memberId: participant.userId, addAmount: false, amount: participant.amountToPay)
        }
        
        // add balance to the payer
        try await GroupManager.shared.updateBalance(groupId: groupId, memberId: paidBy.id, addAmount: true, amount: amount)
    }
}
