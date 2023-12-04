//
//  CategoryManager.swift
//  Debt-Collector
//
//  Created by Martin Sir on 12/3/23.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth

final class CategoryManager {
    
    static let shared = CategoryManager()
    private init () {}
        
    private let categoryCollection = Firestore.firestore().collection("categories")
    
    private func categoryDocument(categoryId: String) -> DocumentReference {
        categoryCollection.document(categoryId)
    }
    
    func getCategories() async throws -> [Category] {
        try await categoryCollection.getDocuments(as: Category.self)
    }
}
