//
//  AuthViewModel.swift
//  Debt-Collector
//
//  Created by Martin Sir on 10/18/23.
//

import Foundation
import Firebase
import FirebaseAuth

class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User? = nil
    @Published var authFailed: Bool = false
    
    init(){
        self.userSession = nil
        self.authFailed = false
    }
    
    func singIn(withEmail email: String, password: String) async throws {
        print("sign in")
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
        } catch {
            print("Problem with signing in user")
            authFailed = true
        }
    }
    
    func createUser(withEmail email: String, password: String) async throws {
        print("sign up")
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user
        } catch {
            print("Problem with creating user")
        }
    }
}
