//
//  Debt_CollectorApp.swift
//  Debt-Collector
//
//  Created by Martin Sir on 10/17/23.
//

import SwiftUI

@main
struct Debt_CollectorApp: App {
    @State var isLoggedIn: Bool = false
    // TODO: check if the user is logged in
    // TODO: finish BE implementation of logging in
    var body: some Scene {
        WindowGroup {
            if isLoggedIn {
                ContentView()
            } else {
                LoginView()
            }
        }
    }
}
