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
    var image: Data?

    init(id: String, name: String, currency: String, image: Data?, owner: User) {
        self.id = id
        self.image = image
        self.name = name
        self.currency = currency
        self.members = [owner]
    }
    
    func addMember(member: User){
        members.append(member)
    }
    func removeMember(member: User) {
        if let index = members.firstIndex(where: { $0.id == member.id }) {
            members.remove(at: index)
        }
    }
    func getAllMembers() -> [User] {
        return members
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
    func getGroupImage() -> Data? {
        return image
    }
    func setGroupName(newName: String) {
        name = newName
    }
    func setGroupCurrency(newCurrency: String) {
        currency = newCurrency
    }
    func setGroupImage(newImage: Data?) {
        image = newImage
    }
    func processPayment(value: Int, payer: User){
        //Ensuring payer is in group
        guard members.contains(where: {$0.id == payer.id}) else {
            return
        }
        
        let paymentPerMember = value / members.count
    }
}

