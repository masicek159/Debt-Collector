//
//  ParticipantModel.swift
//  Debt-Collector
//
//  Created by user248815 on 12/2/23.
//

import Foundation

class Participant: Codable, Identifiable, Hashable {
    var userId: String
    var share: Double
    var amountToPay: Double
    var fullName: String = ""
    
    init(userId: String, share: Double, amountToPay: Double) {
        self.userId = userId
        self.share = share
        self.amountToPay = amountToPay
    }
    
    init(userId: String, fullName: String) {
        self.userId = userId
        self.share = 1
        self.amountToPay = 0
        self.fullName = fullName
    }
    
    enum CodingKeys: String, CodingKey {
        case userId
        case share
        case amountToPay
    }

    static func == (lhs: Participant, rhs: Participant) -> Bool {
        return lhs.userId == rhs.userId
    }
    
    public func hash(into hasher: inout Hasher) {
        return hasher.combine(userId)
    }
    
}
