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
    var image: String? = nil

    init(id: String, name: String, currency: String, image: String? = nil) {
        self.id = id
        self.image = image
        self.name = name
        self.currency = currency
        self.members = [:]
    }
    
    func addMember(member: User){
        members[member] = 0
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
