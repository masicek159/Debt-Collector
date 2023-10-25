//
//  CustomGoogleSignInButton.swift
//  Debt-Collector
//
//  Created by Martin Sir on 23.10.2023.
//

import SwiftUI

struct CustomGoogleSignInButton: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Button {
            Task {
                try await authViewModel.googleSignIn()
            }
        } label: {
            HStack {
                Image("google-logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(6)
                
                Text("Sign in with Google")
                    .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
            }
            .frame(width: UIScreen.main.bounds.width - 32, height: 48)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(colorScheme == .dark ? Color.white : Color.black, lineWidth: 1)
            )
        }
    }
}

#Preview {
    CustomGoogleSignInButton()
}
