//
//  groupClass.swift
//  Debt-Collector
//
//  Created by user248613 on 10/20/23.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

class GroupModel: Codable, Identifiable, Hashable {
    static func == (lhs: GroupModel, rhs: GroupModel) -> Bool {
        lhs.id == rhs.id
    }
    public func hash(into hasher: inout Hasher) {
        return hasher.combine(id)
    }
    
    var id: String = ""
    var members: [User] = []
    var name: String
    var currency: String // TODO: add currency model or currency enum
    var color: String
    
    init(id: String, name: String, currency: String, color: String, owner: User) {
        self.id = id
        self.color = color
        self.name = name
        self.currency = currency
    }
    
    func getGroupID() -> String {
        return id
    }
    func getGroupName() -> String {
        return name
    }
    func getGroupCurrency() -> String {
        return currency
    }
    func getGroupColor() -> UIColor {
        if let data = Data(base64Encoded: self.color) {
            return UIColor.color(data: data)
        }
        return UIColor.blue
    }
    func setGroupName(newName: String) {
        name = newName
    }
    func setGroupCurrency(newCurrency: String) {
        currency = newCurrency
    }
    func setGroupColor(newColor: String) {
        color = newColor
    }
}
