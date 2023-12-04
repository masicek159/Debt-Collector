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
    var balance: Double = 0
    
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
    }

    
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.email == rhs.email
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(email)
    }
    
    func getBalance() -> Double{
        return(balance)
    }
    
    func addBalance(bal: Double){
        balance += bal
    }
    
    func removeBalance(bal: Double){
        balance -= bal
    }
}
