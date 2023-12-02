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
    @EnvironmentObject var swiftUIShared: SwiftUIShared
    @Environment(\.colorScheme) var colorScheme
    @State private var loading: Bool = false
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack {
                    Image("app-logo")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 120, height: 140)
                        .padding(.top, 32)
                        .padding(.vertical, 32)
                    
                    VStack {
                        InputView(text: $email, placeholder: "name@example.com").autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
                            .padding()
                        
                        InputView(text: $password, placeholder: "Enter your password", isSecuredField: true)
                            .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
                            .padding()
                        
                        if authViewModel.authFailed && authViewModel.errorMessage != nil {
                            Text(authViewModel.errorMessage ?? "")
                                .foregroundColor(Color.red)
                                .font(.system(size: 14))
                        }
                        
                        Button {
                            print("Logging in")
                            Task {
                                self.loading = true
                                try await  authViewModel.singIn(withEmail: email, password: password)
                            await fetchDataAndWriteToFile()
                                self.loading = false
                            }
                        } label: {
                            Group{
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
                        .cornerRadius(15)
                        .padding(.top, 24)
                        
                        HStack {
                            VStack { Divider() }
                            Text("or")
                            VStack { Divider() }
                        }
                        
                        CustomGoogleSignInButton()
                        
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
                            .padding(.top, 24)
                            .font(.system(size: 16))
                        }
                    }
                    .padding(.horizontal)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    swiftUIShared.hideKeyboard()
                }
            }}
        .onAppear(perform: authViewModel.resetVariables)
    }
}

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
