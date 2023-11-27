//
//  GroupMember.swift
//  Debt-Collector
//
//  Created by user248815 on 11/27/23.
//

import Foundation

struct GroupMember: Codable {
    let memberId: String
    let balance: Int

    enum CodingKeys: String, CodingKey {
        case memberId = "member_id"
        case balance = "balance"
    }
}
