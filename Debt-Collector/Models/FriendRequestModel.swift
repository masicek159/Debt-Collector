//
//  FriendRequestModel.swift
//  Debt-Collector
//
//  Created by Martin Sir on 28.11.2023.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

class FriendRequest: Codable, Hashable {
    var read: Bool
    var receiverId: String
    var senderId: String
    var sentDate: Timestamp
    var senderFullName: String
    var senderEmail: String
    
    init(read: Bool, receiverId: String, senderId: String, sentDate: Timestamp, senderFullName: String = "", senderEmail: String = "") {
        self.read = read
        self.receiverId = receiverId
        self.senderId = senderId
        self.sentDate = sentDate
        self.senderFullName = senderFullName
        self.senderEmail = senderEmail
    }
    
    enum CodingKeys: String, CodingKey {
        case read
        case receiverId
        case senderId
        case sentDate
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.read = try values.decode(Bool.self, forKey: .read)
        self.receiverId = try values.decode(String.self, forKey: .receiverId)
        self.senderId = try values.decode(String.self, forKey: .senderId)
        self.sentDate = try values.decode(Timestamp.self, forKey: .sentDate)
        self.senderFullName = "" // fullname is loaded later - it has to be from user collection
        self.senderEmail = ""
    }
    
    static func == (lhs: FriendRequest, rhs: FriendRequest) -> Bool {
        return lhs.receiverId == rhs.receiverId && lhs.senderId == rhs.senderId
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(receiverId)
        hasher.combine(senderId)
    }
}
