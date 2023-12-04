//
//  GroupMember.swift
//  Debt-Collector
//
//  Created by user248815 on 11/27/23.
//

import Foundation

class GroupMember: Codable, Identifiable, Hashable {
    var memberId: String
    var balance: Double
    var fullName: String

    init(memberId: String, balance: Double, fullName: String) {
        self.memberId = memberId
        self.balance = balance
        self.fullName = fullName
    }
    
    enum CodingKeys: String, CodingKey {
        case memberId = "memberId"
        case balance = "balance"
    }
    
    required init(from decoder: Decoder) throws{
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.memberId = try values.decode(String.self, forKey: .memberId)
        self.balance = try values.decode(Double.self, forKey: .balance)
        self.fullName = ""
    }
    
    static func == (lhs: GroupMember, rhs: GroupMember) -> Bool {
        lhs.id == rhs.id
    }
    public func hash(into hasher: inout Hasher) {
        return hasher.combine(id)
    }

}
