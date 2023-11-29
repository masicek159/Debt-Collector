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
    
    init() {
        self.viewModel.loadCurrentUser()
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
                            // TODO: finish approve or decline
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
