//
//  userClass.swift
//  Debt-Collector
//
//  Created by user248613 on 10/20/23.
//

import Foundation
class user: Hashable{
    var username: String
    var password: String
    var balance: Int
    var friends: [user] = []
    init(username: String, password: String){
        self.username = username
        self.password = password
        self.balance = 0
        self.friends = []
    }
    static func == (lhs: user, rhs: user) -> Bool {
            return lhs.username == rhs.username
    }
    func hash(into hasher: inout Hasher) {
            hasher.combine(username)
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
    func getFriends() -> [user]{
        return(friends)
    }
    func addFriend(friend: user){
        friends.append(friend)
    }
}
