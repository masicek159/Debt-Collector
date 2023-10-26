//
//  AuthViewModel.swift
//  Debt-Collector
//
//  Created by Martin Sir on 10/18/23.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift
import FirebaseAuth
import GoogleSignIn
import GoogleSignInSwift

@MainActor
class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User? = nil
    @Published var currentUser: User? = nil
    @Published var authFailed: Bool
    @Published var errorMessage: String? = nil
    
    init(){
        self.authFailed = false
        self.errorMessage = nil
        
        Task {
            await fetchFirestoreUser()
        }
    }
    
    func singIn(withEmail email: String, password: String) async throws {
        self.authFailed = false
        self.errorMessage = nil
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            await fetchFirestoreUser()
        } catch {
            print("Problem with creating user: \(error.localizedDescription)")
            self.errorMessage = "You have entered an invalid email or password"
            self.authFailed = true
        }
    }
    
    func createUser(withEmail email: String, password: String, fullName: String) async throws {
        self.authFailed = false
        self.errorMessage = nil
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user
            await createFirestoreUserIfNotExists(uid: result.user.uid, email: email, fullName: fullName)
            await fetchFirestoreUser()
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
            await createFirestoreUserIfNotExists(uid: result.user.uid, email: result.user.email ?? "", fullName: result.user.displayName ?? "")
            await fetchFirestoreUser()
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
    
    func createFirestoreUserIfNotExists(uid: String, email: String, fullName: String) async {
        let userRef = Firestore.firestore().collection("users").document(uid)
        let userDoc = try? await userRef.getDocument()
        if let document = userDoc, document.exists {
            return
        } else {
            let user = User(id: uid, email: email, fullName: fullName)
            guard let encodedUser = try? Firestore.Encoder().encode(user) else { return }
            try? await userRef.setData(encodedUser)
        }
    }
    
    func fetchFirestoreUser() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let snapshot = try? await Firestore.firestore().collection("users").document(uid).getDocument() else { return }
        self.currentUser = try? snapshot.data(as: User.self)
    }
    
    func resetVariables() {
        self.errorMessage = nil
        self.authFailed = false
    }
}
