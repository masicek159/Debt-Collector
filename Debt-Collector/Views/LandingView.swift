//
//  LandingView.swift
//  Debt-Collector
//
//  Created by Martin Sir on 10/18/23.
//

import SwiftUI

struct LandingView: View {
    @State var selectedTab: Int = 1
    
    var body: some View {
        
        TabView(selection: $selectedTab) {
            
            FriendsView()
                .tabItem{
                    Image(systemName: "person.fill")
                    Text("Friends")
                }
                .tag(0)
            
            ChartsView()
                .tabItem{
                    Image(systemName: "chart.bar")
                    Text("Charts")
                }
                .tag(1)
            
            AddExpenseView()
                .tabItem{
                    Image(systemName: "plus.circle.fill")
                    Text("Add expense")
                }
                .tag(2)
            
            GroupsView()
                .tabItem{
                    Image(systemName: "person.2.fill")
                    Text("Groups")
                }
                .tag(3)
            
            ProfileView()
                .tabItem{
                    Image(systemName: "circle.grid.2x2.fill")
                    Text("Profile")
                }
                .tag(4)
            
        }.accentColor(.purple)
    }
        
}

struct LandingView_Previews: PreviewProvider {
    static var previews: some View {
        LandingView()
    }
}
