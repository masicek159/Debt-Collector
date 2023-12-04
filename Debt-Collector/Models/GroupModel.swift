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
    var id: String = ""
    var name: String
    var currency: String // TODO: add currency model or currency enum
    var color: String
    var members: [GroupMember] = []
    var membersAsUsers: [User] = []
    var expenses: [ExpenseModel] = []
    
    init(id: String, name: String, currency: String, color: String, owner: User, members: [GroupMember] = [], membersAsUsers: [User] = [], expenses: [ExpenseModel] = []) {
        self.id = id
        self.color = color
        self.name = name
        self.currency = currency
        self.members = members
        self.membersAsUsers = membersAsUsers
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case currency
        case color
    }
    
    required init(from decoder: Decoder) throws{
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try values.decode(String.self, forKey: .id)
        self.name = try values.decode(String.self, forKey: .name)
        self.currency = try values.decode(String.self, forKey: .currency)
        self.color = try values.decode(String.self, forKey: .color)
        self.members = [] // loaded later from user collection
        self.membersAsUsers = [] // loaded later from user collection
        self.expenses = [] // loaded later from expenses subcollection
    }

    func loadExpensesToGroup() async {
        do {
            try self.expenses =  await ExpenseManager.shared.getExpenses(withinGroup: id)
        } catch {
            self.expenses = []
        }
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
    
    func getMembers() -> [GroupMember] {
        return self.members
    }
    
    static func == (lhs: GroupModel, rhs: GroupModel) -> Bool {
        lhs.id == rhs.id
    }
    public func hash(into hasher: inout Hasher) {
        return hasher.combine(id)
    }
}
