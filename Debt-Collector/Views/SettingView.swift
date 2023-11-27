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
    
    var body: some View {
        VStack {
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
        }
    }
}
