//
//  CustomGoogleSignInButton.swift
//  Debt-Collector
//
//  Created by Martin Sir on 23.10.2023.
//

import SwiftUI

struct CustomGoogleSignInButton: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var swiftUIShared: SwiftUIShared
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Button {
            Task {
                swiftUIShared.showLoadingPage(showLoadingPage: true)
                try await authViewModel.googleSignIn()
                swiftUIShared.showLoadingPage(showLoadingPage: false)
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

struct  CustomGoogleSignInButton_Previews: PreviewProvider {
    static var previews: some View {
        CustomGoogleSignInButton()
    }
}

