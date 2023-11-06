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
    @StateObject var swiftUIShared = SwiftUIShared()
    @StateObject var currenciesHelper = CurrenciesHelper()
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
                .environmentObject(swiftUIShared)
                .environmentObject(currenciesHelper)
        }
    }
}
    
