//
//  ContentView.swift
//  Debt-Collector
//
//  Created by Martin Sir on 10/17/23.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var swiftUIShared: SwiftUIShared
    
    var body: some View {
        ZStack {
            Group {
                if authViewModel.userSession != nil && authViewModel.showLandingView {
                    LandingView()
                } else {
                    LoginView()
                }
            }
            
            if swiftUIShared.showLoadingPage {
                LoadingPageView()
            }
        }
    }
}


struct ContentView_Preview: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
