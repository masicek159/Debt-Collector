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
                .tabItem{
                    Image(systemName: "person.fill")
                    Text("Friends")
                }
            ChartsView()
                .tabItem{
                    Image(systemName: "chart.bar")
                    Text("Charts")
                }
            AddExpenseView()
                .tabItem{
                    Image(systemName: "plus.circle.fill")
                    Text("Add expense")
                }
            GroupsView()
                .tabItem{
                    Image(systemName: "person.2.fill")
                    Text("Groups")
                }
            SettingView()
                .tabItem{
                    Image(systemName: "circle.grid.2x2.fill")
                    Text("Settings")
                }
            
        }.accentColor(.purple)
        
    }
}

struct LandingView_Previews: PreviewProvider {
    static var previews: some View {
        LandingView()
    }
}
