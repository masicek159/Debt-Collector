//
//  LoginView.swift
//  Debt-Collector
//
//  Created by Martin Sir on 10/17/23.
//

import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                InputView(text: $email, title: "Email Address", placeholder: "name@example.com").autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
                
                InputView(text: $password, title: "Password", placeholder: "Enter your password", isSecuredField: true).autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
            }
            .padding(.horizontal)
            
            
            Button {
                print("Logging in")
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
            .cornerRadius(10)
            .padding(.top, 24)
            
            Spacer()
            
            NavigationLink {
                SignUpView()
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

#Preview {
    LoginView()
}
