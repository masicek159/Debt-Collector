//
//  GroupsView.swift
//  Debt-Collector
//
//  Created by user248815 on 10/19/23.
//

import SwiftUI

struct GroupsView: View {
    @ObservedObject var groupViewModel = GroupViewModel()
    @State private var showPopup = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(groupViewModel.groups, id: \.id) { group in
                    NavigationLink(destination: GroupDetail(group: group)) {
                        HStack {
                            Text(group.name)
                        }
                    }
                    .navigationBarBackButtonHidden(true)
                }
            }
            .navigationTitle("My Groups")
            .navigationBarItems(trailing: Button(action: {
                showPopup.toggle()
            }, label: {
                Image(systemName: "plus")
            }))
            .sheet(isPresented: $showPopup, content: {
                NewGroupView(viewModel: groupViewModel, showPopup: $showPopup)
            })
            .task {
                groupViewModel.getGroups()
            }
        }
    }
}
