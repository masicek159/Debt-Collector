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
    
    func addExpense(name: String, amount: Double, category: Category?, currency: String, groupId: String, paidBy: User, participants: [User]) async throws {
        try await ExpenseManager.shared.uploadExpense(name: name, amount: amount, category: category, currency: currency, groupId: groupId, paidBy: paidBy, participants: participants)
    }
}
