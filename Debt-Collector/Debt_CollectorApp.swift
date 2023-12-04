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
    @StateObject var authViewModel: AuthViewModel = AuthViewModel()
    @StateObject var swiftUIShared: SwiftUIShared = SwiftUIShared()
    @StateObject var categoryViewModel: CategoryViewModel = CategoryViewModel()
    @StateObject var groupViewModel: GroupViewModel = GroupViewModel()
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
                .environmentObject(swiftUIShared)
                .environmentObject(categoryViewModel)
                .environmentObject(groupViewModel)
        }
    }
}

//class AppDelegate: NSObject, UIApplicationDelegate {
//    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
//        FirebaseApp.configure()
//        return true
//    }				
//}
