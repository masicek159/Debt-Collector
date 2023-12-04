//
//  GroupManager.swift
//  Debt-Collector
//
//  Created by Martin Sir on 04.11.2023.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth

final class ExpenseManager {
    
    static let shared = ExpenseManager()
    private init () {}
        
    private let groupCollection = Firestore.firestore().collection("groups")
    
    private func groupDocument(groupId: String) -> DocumentReference {
        groupCollection.document(groupId)
    }
    
    private func groupExpenseCollection(groupId: String) -> CollectionReference {
        groupDocument(groupId: groupId).collection("expenses")
    }
    
    private func groupExpenseDocument(expenseId: String, groupId: String) -> DocumentReference {
        groupExpenseCollection(groupId: groupId).document(expenseId)
    }
    
    func uploadExpense(name: String, amount: Double, category: Category?, currency: String, groupId: String, paidBy: User, participants: [Participant]) async throws {
        let expenseRef = groupExpenseCollection(groupId: groupId).document()
        let expense = ExpenseModel(id: expenseRef.documentID, name: name, amount: amount, category: category, currency: currency, groupId: groupId, paidBy: paidBy, participants: participants)
        try expenseRef.setData(from: expense, merge: false)
    }
}
