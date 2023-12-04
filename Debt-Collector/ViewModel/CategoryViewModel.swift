//
//  CategoryViewModel.swift
//  Debt-Collector
//
//  Created by Martin Sir on 12/3/23.
//

import Foundation

@MainActor
final class CategoryViewModel: ObservableObject {
    @Published private(set) var categories: [Category] = []
    
    func loadCategories() async {
        do {
            categories = try await CategoryManager.shared.getCategories()
        } catch {
            categories = []
        }
    }
}
