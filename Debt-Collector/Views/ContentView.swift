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
    @EnvironmentObject var categoryViewModel: CategoryViewModel
    
    var body: some View {
        ZStack {
            Group {
                if authViewModel.userSession != nil && authViewModel.showLandingView {
                    LandingView()
                        .task {
                            await categoryViewModel.loadCategories()
                        }
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
