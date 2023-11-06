//
//  GroupsView.swift
//  Debt-Collector
//
//  Created by user248815 on 10/19/23.
//

import SwiftUI

@MainActor
final class GroupsViewModel: ObservableObject {
    @Published private(set) var groups: [GroupModel] = []
    
    func addGroup(name: String, currency: String, image: String = "") async throws {
        try await GroupManager.shared.uploadGroup(name: name, currency: currency, image: image)
    }
    
    func getGroups () {
        Task {
            let userGroups = try await UserManager.shared.getAllUserGroups()
            
            var localArray: [GroupModel] = []
            
            for userGroup in userGroups {
                if let group = try? await GroupManager.shared.getGroup(groupId: userGroup.groupId) {
                    localArray.append( group)
                    print(group.id)
                }
            }
            self.groups = localArray
            print(self.groups)
        }
    }
}

struct GroupsView: View {
    @ObservedObject var viewModel = GroupsViewModel()
    @State private var showPopup = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.groups, id: \.id) { group in
                    // TODO: group view
                    Text(group.name)
                }
            }
            .navigationTitle("My Groups")
            .navigationBarItems(trailing: Button(action: {
                showPopup.toggle()
            }, label: {
                Image(systemName: "plus")
            }))
            .sheet(isPresented: $showPopup, content: {
                NewGroupView(viewModel: viewModel, showPopup: $showPopup)
            })
            .task {
                viewModel.getGroups()
            }
        }
    }
}

struct GroupsView_Previews: PreviewProvider {
    static var previews: some View {
        GroupsView()
    }
}
