//
//  LoginView.swift
//  Debt-Collector
//
//  Created by Martin Sir on 10/17/23.
//

import SwiftUI
import GoogleSignIn
import GoogleSignInSwift

protocol AuthenticationFormProtocol {
    var isFormValid: Bool { get }
}

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        NavigationStack {
            VStack {
                Image("logo")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 120, height: 140)
                    .padding(.top, 32)
                    .padding(.vertical, 32)
        
                InputView(text: $email, title: "Email Address", placeholder: "name@example.com").autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
                    .border(authViewModel.authFailed ? Color.red : Color.clear)
                
                InputView(text: $password, title: "Password", placeholder: "Enter your password", isSecuredField: true).autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
                    .border(authViewModel.authFailed ? Color.red : Color.clear)

                
                if authViewModel.authFailed {
                    Text("auth failed")
                        .foregroundColor(Color.red)
                }
            }
            .padding(.horizontal)
            
            
            Button {
                print("Logging in")
                Task {
                    try await  authViewModel.singIn(withEmail: email, password: password)
                }
            } label: {
                HStack{
                    Text("SIGN IN")
                        .fontWeight(.semibold)
                    Image(systemName: "arrow.right")
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
            
            GoogleSignInButton(viewModel: GoogleSignInButtonViewModel(scheme: .light, style: .wide, state: .normal)) {
                Task {
                    try await authViewModel.googleSignIn()
                }
            }
            
            Spacer()
            
            NavigationLink {
                SignUpView()
                    .navigationBarBackButtonHidden()
            } label: {
                HStack(spacing: 3) {
                    Text("Don't have an account?")
                    Text("Sign up!")
                        .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                }
                .font(.system(size: 14))
            }
        }
    }}


extension LoginView: AuthenticationFormProtocol {
    var isFormValid: Bool {
        return !email.isEmpty
        && email.contains("@")
        && !password.isEmpty
        && password.count > 5
    }
}

struct LoginView_Preview: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
