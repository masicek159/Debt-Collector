//
//  GroupsView.swift
//  Debt-Collector
//
//  Created by user248815 on 10/19/23.
//

import SwiftUI

struct GroupsView: View {
    @ObservedObject var groupViewModel: GroupViewModel = GroupViewModel()
    @State private var showPopup = false
    @State private var groupToDelete: GroupModel?
    @State private var showDeleteAlert = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(groupViewModel.groups, id: \.id) { group in
                    NavigationLink(destination: GroupDetail(group: group)) {
                        HStack {
                            Text(group.name)
                        }
                        .swipeActions {
                            Button {
                                groupToDelete = group
                                showDeleteAlert = true
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            .tint(.red)
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
            .alert(isPresented: $showDeleteAlert) {
                Alert(
                    title: Text("Delete Group"),
                    message: Text("Are you sure you want to delete \(groupToDelete?.name ?? "this group")?"),
                    primaryButton: .destructive(Text("Delete"), action: {
                        if let groupToDelete = groupToDelete {
                            groupViewModel.deleteGroup(groupId: groupToDelete.id)
                        }
                    }),
                    secondaryButton: .cancel()
                )
            }
            .task {
                groupViewModel.getGroups()
            }
        }
    }
}
