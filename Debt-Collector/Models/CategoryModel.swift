//
//  CategoryModel.swift
//  Debt-Collector
//
//  Created by Martin Sir on 12/3/23.
//

import Foundation

class Category: Identifiable, Codable, Hashable {
    var id: String
    var name: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
    }
    
    init(id: String, name: String) {
        self.id = id
        self.name = name
    }
    
    static func == (lhs: Category, rhs: Category) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        return hasher.combine(id)
    }
}

