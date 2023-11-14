//
//  groupClass.swift
//  Debt-Collector
//
//  Created by user248613 on 10/20/23.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

class GroupModel: Codable, Identifiable {
    var id: String = ""
    var members: [User: Int]
    var name: String
    var currency: String // TODO: add currency model or currency enum
    var image: Data?

    init(id: String, name: String, currency: String, image: Data?) {
        self.id = id
        self.image = image
        self.name = name
        self.currency = currency
        self.members = [:]
    }
    deinit {
        // Delete the corresponding document from Firestore
        let groupCollection = Firestore.firestore().collection("groups")
        let groupDocument = groupCollection.document(id)
            
        groupDocument.delete { error in
            if let error = error {
                print("Error deleting group document: \(error)")
            } else {
                print("Group document deleted successfully.")
            }
        }
    }
    func addMember(member: User){
        members[member] = 0
    }
    func removeMember(member: User) {
        members.removeValue(forKey: member)
    }
    func getAllMembers() -> [User] {
        return Array(members.keys)
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
        guard members.keys.contains(payer) else {
            return
        }
        members[payer]! += value
        var debt = value/members.count
        for (member, _) in members {
            if member != payer {
                members[member]! -= debt
            }
        }
    }
    
}
