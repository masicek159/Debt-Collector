//
//  groupClass.swift
//  Debt-Collector
//
//  Created by user248613 on 10/20/23.
//

import Foundation
class group{
    var members: [User: Int]
    init(){
        members = [:]
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
