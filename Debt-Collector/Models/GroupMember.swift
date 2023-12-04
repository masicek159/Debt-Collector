//
//  GroupMember.swift
//  Debt-Collector
//
//  Created by user248815 on 11/27/23.
//

import Foundation

struct GroupMember: Codable {
    let memberId: String
    let balance: Double

    enum CodingKeys: String, CodingKey {
        case memberId = "memberId"
        case balance = "balance"
    }
}
