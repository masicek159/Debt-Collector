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
    
    @StateObject private var profileViewModel = ProfileViewModel()
    @StateObject private var friendRequestViewModel: FriendRequestViewModel = FriendRequestViewModel()
    @StateObject private var userViewModel: UserViewModel = UserViewModel()
    
    @State private var addFailed: Bool = false
    @State private var showAlert: Bool = false
    
    init() {
        self.profileViewModel.loadCurrentUser()
    }
    
    func acceptFriendRequest(friendRequest: FriendRequest, friendsRequestViewModel: FriendRequestViewModel, userViewModel: UserViewModel) async{

        // add friend to receiver
        do {
            try await userViewModel.addFriend(userId: friendRequest.receiverId, friendId: friendRequest.senderId)
        } catch {
            print("Cannot add friend \(friendRequest.senderId) to user \(friendRequest.receiverId)")
        }
        // add friend to sender
        do {
            try await userViewModel.addFriend(userId: friendRequest.senderId, friendId: friendRequest.receiverId)
        } catch {
            print("Cannot add friend \(friendRequest.receiverId) to user \(friendRequest.senderId)")
        }
        // update the request to accepted
        friendsRequestViewModel.updateRequestStatus(updatedStatus: "ACCEPTED", requestId: friendRequest.id)
        await friendsRequestViewModel.loadFriendRequests()
    }

    func declineFriendRequest(friendRequest: FriendRequest, friendsRequestViewModel: FriendRequestViewModel) async{
        // update the request to declined
        friendsRequestViewModel.updateRequestStatus(updatedStatus: "DECLINED", requestId: friendRequest.id)
        await friendsRequestViewModel.loadFriendRequests()
    }
    
    var body: some View {
        NavigationView {
            List {
                Section() {
                    if let user = profileViewModel.user {
                        Text("Name: \(user.fullName)")
                        Text("Email: \(user.email)")
                        Text("Balance: \(user.balance)")
                    }
                }
                
                Section(header: Text("Friend requests")) {
                    ForEach(friendRequestViewModel.friendRequests, id: \.self) { friendRequest in
                        HStack{
                            Text(friendRequest.senderEmail)
                            Spacer()
                            
                            // accept request
                            Button(action: {
                                showAlert = true
                            }) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.green)
                            }
                            .alert(isPresented: $showAlert) {
                                Alert(
                                    title: Text("Do you want to add this user as your friend?"),
                                    message: Text("By clicking on 'Accept' you will become friends with this user"),
                                    primaryButton: .default(
                                        Text("Accept"),
                                        action: {
                                            Task {
                                                await acceptFriendRequest(friendRequest: friendRequest, friendsRequestViewModel: friendRequestViewModel, userViewModel: userViewModel)
                                            }
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
                                Image(systemName: "xmark")
                                    .foregroundColor(.red)
                            }
                            .alert(isPresented: $showAlert) {
                                Alert(
                                    title: Text("Do you really want to decline this user's request?"),
                                    message: Text("By clicking on 'Decline' you will remove this user's friend request"),
                                    primaryButton: .default(
                                        Text("Decline"),
                                        action: {
                                            Task {
                                                await declineFriendRequest(friendRequest: friendRequest, friendsRequestViewModel: friendRequestViewModel)
                                            }
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
            profileViewModel.loadCurrentUser()
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
