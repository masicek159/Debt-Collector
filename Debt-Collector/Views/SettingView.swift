//
//  SettingView.swift
//  Debt-Collector
//
//  Created by user248815 on 10/19/23.
//

import SwiftUI

struct SettingView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        VStack {
            Text("Settings")
            
            Button {
                authViewModel.signOut()
            } label: {
                Text("Sign out")
            }
        }
    }
}

