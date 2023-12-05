//
//  SettingView.swift
//  Debt-Collector
//
//  Created by user248815 on 10/19/23.
//

import SwiftUI

struct SettingView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State var confirmationShown = false
    @Environment(\.presentationMode) var presentationMode
    @Binding var showingSettings: Bool
    
    var body: some View {
        VStack {
            Button(action: {
                showingSettings = false
            }) {
                Text("Cancel")
                    .foregroundColor(.purple)
            }
            
            Spacer()
            
            Text("Settings")
            
            Button {
                confirmationShown = true
            } label: {
                Text("Sign out")
                    .foregroundColor(.purple)
            }
            .alert(isPresented: $confirmationShown) {
                Alert(
                    title: Text("Confirmation"),
                    message: Text("Are you sure you want to Sign Out?"),
                    primaryButton: .default(Text("Yes")) {
                        authViewModel.signOut()
                    },
                    secondaryButton: .cancel() {
                        confirmationShown = false
                    }
                )
            }
            
            Spacer()
        }
        .padding()
    }
}
