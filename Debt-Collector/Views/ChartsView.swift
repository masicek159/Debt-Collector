//
//  ChartsView.swift
//  Debt-Collector
//
//  Created by user248815 on 10/19/23.
//

import SwiftUI
import SwiftUICharts

struct ChartsView: View {
    @State private var groups: [GroupModel] = []

    var body: some View {
        List(groups, id: \.id) { group in
            Text(group.name)
        }
        .onAppear {
            // Call a function to fetch and display the list of groups for the current user
            getGroupsForCurrentUser()
        }
    }

    func getGroupsForCurrentUser() {
        Task {
            do {
                guard let userId = await AuthViewModel.shared.currentUser?.id else { return }
                let userGroups = try await UserManager.shared.getAllUserGroups(userId: userId)

                // Fetch detailed group data for each group ID
                var detailedGroups: [GroupModel] = []
                for userGroup in userGroups {
                    do {
                        let group = try await GroupManager.shared.getGroup(groupId: userGroup.groupId)
                        detailedGroups.append(group)
                        
                        // Print out the group data
                        print("Fetched Group ID: \(group.id), Name: \(group.name), Members: \(group.members)")
                    } catch {
                        print("Error fetching group data for group ID \(userGroup.groupId): \(error)")
                    }
                }

                // Update the groups array
                groups = detailedGroups
            } catch {
                print("Error fetching user groups: \(error)")
            }
        }
    }
}

struct ChartsView_Previews: PreviewProvider {
    static var previews: some View {
        ChartsView()
    }
}
