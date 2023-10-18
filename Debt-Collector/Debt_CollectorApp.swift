//
//  Debt_CollectorApp.swift
//  Debt-Collector
//
//  Created by Martin Sir on 10/17/23.
//

import SwiftUI
import Firebase

@main
struct Debt_CollectorApp: App {
    @StateObject var authViewModel = AuthViewModel()
    
    init() {
        FirebaseApp.configure()
    }
    
    // TODO: check if the user is logged in
    // TODO: finish BE implementation of logging in
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
        }
    }
}
    