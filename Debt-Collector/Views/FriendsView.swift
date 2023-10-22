//
//  FriendsView.swift
//  Debt-Collector
//
//  Created by user248815 on 10/19/23.
//

import SwiftUI

struct FriendsView: View {
    var friends: [user]

    var body: some View {
        NavigationView {
                    VStack {
                        List {
                            Section(header: Text("Balances")) {
                                
                                HStack{
                                    VStack {
                                        Text("Positive Balance:")
                                            .font(.headline)
                                        Spacer()
                                        Text("\(calculateTotalPositiveBalance())$")
                                            .font(.title)
                                            .foregroundColor(.green)
                                    }
                                    Spacer()
                                    Divider()
                                    Spacer()
                                    VStack {
                                        Text("Negative Balance:")
                                            .font(.headline)
                                        Spacer()
                                        Text("-\(calculateTotalNegativeBalance())$")
                                            .font(.title)
                                            .foregroundColor(.red)
                                    }
                                }
                                }
                                
                        
                            Section(header: Text("Friends")) {
                                ForEach(friends, id: \.self) { friend in
                                    HStack {
                                        Image(systemName: "person.fill")
                                            .font(.largeTitle)
                                            .foregroundColor(.purple)
                                        Text(friend.username)
                                            .font(.headline)
                                        Spacer()
                                        Text("Balance: \(friend.balance)$")
                                            .font(.subheadline)
                                            .foregroundColor(friend.balance >= 0 ? .green : .red)
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(GroupedListStyle())
                    .navigationBarTitle("Friends")
                    .navigationBarTitleDisplayMode(.inline)

                }
    }
    func calculateTotalPositiveBalance() -> String {
            let totalPositiveBalance = friends.filter { $0.balance >= 0 }.reduce(0) { $0 + $1.balance }
            return String(totalPositiveBalance)
        }
    func calculateTotalNegativeBalance() -> String {
            let totalNegativeBalance = friends.filter { $0.balance < 0 }.reduce(0) { $0 + $1.balance }
            return String(totalNegativeBalance)
        }

}
