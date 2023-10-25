//
//  AuthViewModel.swift
//  Debt-Collector
//
//  Created by Martin Sir on 10/18/23.
//

import Foundation
import Firebase
import FirebaseAuth
import GoogleSignIn
import GoogleSignInSwift

class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User? = nil
    @Published var authFailed: Bool
    @Published var errorMessage: String? = nil
    
    init(){
        self.userSession = nil
        self.authFailed = false
        self.errorMessage = nil
    }
    
    func singIn(withEmail email: String, password: String) async throws {
        self.authFailed = false
        self.errorMessage = nil
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
        } catch {
            print("Problem with creating user: \(error.localizedDescription)")
            self.errorMessage = error.localizedDescription
            self.authFailed = true
        }
    }
    
    func createUser(withEmail email: String, password: String) async throws {
        self.authFailed = false
        self.errorMessage = nil
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user
        } catch {
            print("Problem with creating user: \(error.localizedDescription)")
            self.errorMessage = error.localizedDescription
            self.authFailed = true
        }
    }
    
    func googleSignIn() async throws -> Bool {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            fatalError("No client ID found in Firebase configuration")
        }
        
        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        guard let windowScene = await UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = await windowScene.windows.first,
              let rootViewController = await window.rootViewController else {
            print("There is no root view controller")
            return false
        }
        
        do {
            let userAuthentication = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
            let user = userAuthentication.user
            guard let idToken = user.idToken?.tokenString else {
                return false
            }
            let accessToken = user.accessToken.tokenString
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
            let result = try await Auth.auth().signIn(with: credential)
            let firebaseUser = result.user
            self.userSession = firebaseUser
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.userSession = nil
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func resetVariables() {
        self.errorMessage = nil
        self.authFailed = false
    }
}
