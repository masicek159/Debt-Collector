//
//  ProfileView.swift
//  Debt-Collector
//
//  Created by user248815 on 11/6/23.
//

import SwiftUI

@MainActor
final class ProfileViewModel: ObservableObject {
    
    @Published var user: User?
    
    func loadCurrentUser(){
        self.user = AuthViewModel.shared.currentUser
    }
}

struct ProfileView: View {
    
    @StateObject private var viewModel = ProfileViewModel()
    @StateObject private var friendRequestViewModel: FriendRequestViewModel = FriendRequestViewModel()
    
    @State private var addFailed: Bool = false
    @State private var showAlert: Bool = false
    
    init() {
        self.viewModel.loadCurrentUser()
    }
    
    func acceptFriendRequest() {
        
    }

    func declineFriendRequest() {
        
    }
    
    var body: some View {
        NavigationView {
            List {
                Section() {
                    if let user = viewModel.user {
                        Text("Name: \(user.fullName)")
                        Text("Email: \(user.email)")
                        Text("Balance: \(user.balance)")
                    }
                }
                
                Section(header: Text("Friend requests")) {
                    ForEach(friendRequestViewModel.friendRequests, id: \.self) { friendRequest in
                        HStack{
                            Text(friendRequest.senderEmail)
                            
                            // accept request
                            Button(action: {
                                showAlert = true
                            }) {
                                Text("Accept")
                            }
                            .alert(isPresented: $showAlert) {
                                Alert(
                                    title: Text("Do you want to add this user as your friend?"),
                                    message: Text("By clicking on 'Accept' you will become friends with this user"),
                                    primaryButton: .default(
                                        Text("Accept"),
                                        action: {
                                            acceptFriendRequest()
                                            showAlert = false
                                        }
                                    ),
                                    secondaryButton: .destructive(
                                        Text("Cancel"),
                                        action: {
                                            showAlert = false
                                        }
                                    )
                                )
                            }
                            
                            // decline request
                            Button(action: {
                                showAlert = true
                            }) {
                                Text("Decline")
                            }
                            .alert(isPresented: $showAlert) {
                                Alert(
                                    title: Text("Do you really want to decline this user's request?"),
                                    message: Text("By clicking on 'Decline' you will remove this user's friend request"),
                                    primaryButton: .default(
                                        Text("Decline"),
                                        action: {
                                            declineFriendRequest()
                                            showAlert = false
                                        }
                                    ),
                                    secondaryButton: .destructive(
                                        Text("Cancel"),
                                        action: {
                                            showAlert = false
                                        }
                                    )
                                )
                            }
                        }
                    }
                }
            }
        }
        .onAppear() {
            viewModel.loadCurrentUser()
        }
        .navigationTitle("Profile")
        .task {
            await friendRequestViewModel.loadFriendRequests()
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
