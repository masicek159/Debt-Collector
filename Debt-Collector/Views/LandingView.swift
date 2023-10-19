//
//  LandingView.swift
//  Debt-Collector
//
//  Created by Martin Sir on 10/18/23.
//

import SwiftUI

struct LandingView: View {
    var body: some View {
        TabView {
            
            FriendsView()
            ChartsView()
            AddExpenseView()
            GroupsView()
            SettingView()
        }.accentColor(.purple)
        
    }
}

struct LandingView_Previews: PreviewProvider {
    static var previews: some View {
        LandingView()
    }
}
