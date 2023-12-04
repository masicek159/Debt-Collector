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
                        HStack {
                            VStack {
                                Text("Positive Balance:")
                                    .font(.headline)
                                Spacer()
                                Text("\(userViewModel.positiveBalance)$")
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
                                Text("\(userViewModel.negativeBalance)$")
                                    .font(.title)
                                    .foregroundColor(.red)
                            }
                        }
                    }

                    Section(header: FriendsSectionHeaderView(showPopup: $showPopup, isFriendListExpanded: $isFriendListExpanded)) {
                        if userViewModel.friends.isEmpty {
                            Text("You do not have any friends.")
                        } else {
                            ForEach(userViewModel.friends, id: \.id) { friend in
                                HStack {
                                    Image(systemName: "person.fill")
                                        .font(.largeTitle)
                                        .foregroundColor(.purple)
                                    Text("\(friend.fullName)")
                                        .font(.headline)
                                }
                            }
                        }
                    }
                    .sheet(isPresented: $showPopup, content: {
                        AddFriendView(showPopup: $showPopup)
                    })
                    .onAppear {
                        userViewModel.getFriends()
                        userViewModel.fetchBalances() // Fetch balances when the view appears
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
}

struct FriendsView_Previews: PreviewProvider {
    static var previews: some View {
        FriendsView()
    }
}
