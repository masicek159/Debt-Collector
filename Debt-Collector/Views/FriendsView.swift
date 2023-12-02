//
//  FriendsView.swift
//  Debt-Collector
//
//  Created by user248815 on 10/19/23.
//

import SwiftUI
import FirebaseAuth

struct FriendsView: View {

    @ObservedObject var userViewModel = UserViewModel()
    @State var showPopup = false
    @State var isFriendListExpanded = true

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
                                Text("\(userViewModel.calculateTotalPositiveBalance())$")
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
                                Text("\(userViewModel.calculateTotalNegativeBalance())$")
                                    .font(.title)
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    
                    Section(header: FriendsSectionHeaderView(showPopup: $showPopup, isFriendListExpanded: $isFriendListExpanded)) {
                        if isFriendListExpanded {
                            if userViewModel.friendsWithExpenses.isEmpty {
                                Text("You do not have any friends.")
                            } else {
                                ForEach(userViewModel.friendsWithExpenses, id: \.friendId) { friendship in
                                    HStack {
                                        Image(systemName: "person.fill")
                                            .font(.largeTitle)
                                            .foregroundColor(.purple)
                                        Text(friendship.friendId)
                                            .font(.headline)
                                        Spacer()
                                        Text("Balance: \(friendship.balance)$")
                                            .font(.subheadline)
                                            .foregroundColor(friendship.balance >= 0 ? .green : .red)
                                    }
                                }
                            }
                        }
                    }
                    .sheet(isPresented: $showPopup, content: {
                        AddFriendView(showPopup: $showPopup)
                    })
                    .onAppear {
                        userViewModel.getFriends()
                    }
                }
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle("Friends")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        ProfileView()
                    } label: {
                        Image(systemName: "person.fill")
                            .font(.headline)
                    }
                    
                }
            }
            
        }
    }
    
/*    func calculateTotalPositiveBalance() -> String {
            let totalPositiveBalance = friends.filter { $0.balance >= 0 }.reduce(0) { $0 + $1.balance }
            return String(totalPositiveBalance)
        }
    func calculateTotalNegativeBalance() -> String {
            let totalNegativeBalance = friends.filter { $0.balance < 0 }.reduce(0) { $0 + $1.balance }
            return String(totalNegativeBalance)
        }
*/
}
