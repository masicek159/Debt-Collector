//
//  userClass.swift
//  Debt-Collector
//
//  Created by user248613 on 10/20/23.
//

import Foundation

class User: Hashable, Identifiable, Codable {
    var email: String
    var fullName: String
    var id: String
    var balance: Int = 0
    var friends: [FriendshipModel] = []
    
    enum CodingKeys: String, CodingKey {
            case email
            case fullName
            case id
            case balance
        }
    
    init(id: String, email: String, fullName: String){
        self.email = email
        self.id = id
        self.fullName = fullName
        
        loadFriends()
    }
    
    func loadFriends() {
        // TODO: call firestore and get friends
    }
    
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.email == rhs.email
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(email)
    }
    
    func getBalance() -> Int{
        return(balance)
    }
    
    func addBalance(bal: Int){
        balance += bal
    }
    
    func removeBalance(bal: Int){
        balance -= bal
    }
    
    func getFriends() -> [FriendshipModel]{
        return(friends)
    }
    
    func addFriend(friend: FriendshipModel){
        friends.append(friend)
    }
}
