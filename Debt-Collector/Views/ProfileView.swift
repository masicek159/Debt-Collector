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
    @State private var showingSettings = false
    
    init() {
        self.viewModel.loadCurrentUser()
    }
    
    var body: some View {
        NavigationView {
            
            List {
                if let user = viewModel.user {
                    Text("Name: \(user.fullName)")
                    Text("Email: \(user.email)")
                    Text("Balance: \(user.balance)")
                }
            }
            .onAppear() {
                viewModel.loadCurrentUser()
            }
            .navigationTitle("Profile")
            .navigationBarItems(trailing:
                            Button(action: {
                                showingSettings = true
                            }) {
                                Image(systemName: "gearshape")
                                    .font(.title2)
                                    .foregroundColor(.purple)
                                    .frame(width: 30, height: 30)
                            }
                        )
                        .sheet(isPresented: $showingSettings) {
                            SettingView()
                        }
                
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
