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
    
    func getExpense(expenseId: String, groupId: String) async throws -> ExpenseModel {
        let expenseDocument = try await groupExpenseDocument(expenseId: expenseId, groupId: groupId).getDocument()
            let expense = try expenseDocument.data(as: ExpenseModel.self)
                
            return expense
    }
    func deleteExpenseFromFirebase(expenseId: String, groupId: String) async throws {
        // Implement the logic to delete the expense document from Firebase
        // For example:
        let expenseDocument = Firestore.firestore().collection("groups").document(groupId).collection("expenses").document(expenseId)
        
        try await expenseDocument.delete()
        
    }
    func uploadExpense(name: String, amount: Double, category: Category?, currency: String, groupId: String, paidBy: User, participants: [Participant], dateCreated: Date) async throws {
        let expenseRef = groupExpenseCollection(groupId: groupId).document()
        let expense = ExpenseModel(id: expenseRef.documentID, name: name, amount: amount, category: category, currency: currency, groupId: groupId, paidBy: paidBy, dateCreated: dateCreated, participants: participants)
        try expenseRef.setData(from: expense, merge: false)
    }
    
    func updateExpense(expenseId: String, name: String, amount: Double, category: Category?, currency: String, groupId: String, paidBy: User, participants: [Participant], dateCreated: Date) async throws {
        let expenseRef = groupExpenseCollection(groupId: groupId).document(expenseId)
        let expense = ExpenseModel(id: expenseRef.documentID, name: name, amount: amount, category: category, currency: currency, groupId: groupId, paidBy: paidBy, dateCreated: dateCreated, participants: participants)
        print(paidBy)
        try expenseRef.setData(from: expense, merge: true)
    }
    
    func getExpenses(withinGroup groupId: String) async throws -> [ExpenseModel] {
        try await groupExpenseCollection(groupId: groupId).order(by: "dateCreated", descending: true).getDocuments(as: ExpenseModel.self)
    }
}
