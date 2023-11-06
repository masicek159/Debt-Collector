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
    
    var body: some View {
        NavigationView {
            
            List {
                if let user = viewModel.user {
                    Text("UserID: \(user.id)")
                }
            }
            .onAppear {
                viewModel.loadCurrentUser()
            }
            .navigationTitle("Profile")
                
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
