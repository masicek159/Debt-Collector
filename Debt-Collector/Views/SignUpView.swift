//
//  SignUpView.swift
//  Debt-Collector
//
//  Created by Martin Sir on 10/17/23.
//

import SwiftUI
import GoogleSignIn
import GoogleSignInSwift

struct SignUpView: View {
    @State private var email = ""
    @State private var fullName = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var loading = false
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack {
                Image("app-logo")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 120, height: 140)
                    .padding(.top, 24)
                    .padding(.vertical, 32)
                
                InputView(text: $fullName, placeholder: "Full name")
                    .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
                    .padding()
                
                InputView(text: $email, placeholder: "name@example.com")
                    .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
                    .padding()
                
                InputView(text: $password, placeholder: "Enter your password", isSecuredField: true)
                    .padding()
                
                InputView(text: $confirmPassword, placeholder: "Confirm your password", isSecuredField: true)
                    .padding()
                
                if authViewModel.authFailed && authViewModel.errorMessage != nil {
                    Text(authViewModel.errorMessage ?? "")
                        .foregroundColor(Color.red)
                        .font(.system(size: 14))
                }
            }
            .padding(.horizontal)
            
            Button {
                print("Logging in")
                Task {
                    self.loading = true
                    try await authViewModel.createUser(withEmail: email, password: password)
                    self.loading = false
                }
            } label: {
                Group {
                    if self.loading {
                        Text("Loading...")
                            .fontWeight(.semibold)
                    } else {
                        HStack{
                            Text("SIGN IN")
                                .fontWeight(.semibold)
                            Image(systemName: "arrow.right")
                        }
                    }
                }
                .foregroundColor(.white)
                .frame(width: UIScreen.main.bounds.width - 32, height: 48)
            }
            .background(Color(.systemBlue))
            .disabled(!isFormValid)
            .opacity(isFormValid ? 1.0 : 0.5)
            .cornerRadius(10)
            .padding(.top, 24)
            
            HStack {
                VStack { Divider() }
                Text("or")
                VStack { Divider() }
            }
            
            CustomGoogleSignInButton()
            
            Spacer()
            
            Button {
                // return back to log in page
                dismiss()
            } label: {
                HStack(spacing: 3) {
                    Text("Already have an account?")
                    Text("Sign in!")
                        .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                }
                .padding(.top, 24)
                .font(.system(size: 16))
            }
        }
        .onAppear(perform: authViewModel.resetVariables)
    }
}

extension SignUpView: AuthenticationFormProtocol {
    var isFormValid: Bool {
        return !email.isEmpty
        && email.contains("@")
        && !password.isEmpty
        && password.count > 5
    }
}
struct SignUpView_Preview: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}
