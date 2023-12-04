//
//  ChartsView.swift
//  Debt-Collector
//
//  Created by user248815 on 10/19/23.
//

import SwiftUI
import SwiftUICharts

struct ChartsView: View {
    @ObservedObject var groupViewModel = GroupViewModel()
    @ObservedObject var categoryViewModel = CategoryViewModel()
    @State var groups: [GroupModel] = []
    @State var selectedGroup: GroupModel? = nil
    @State var selectedParticipantId: String? = nil
    @State var selectedPaidByUserId: String? = nil
    @State var selectedCategory: Category? = nil
    @State var filteredExpenses: [ExpenseModel] = []
    
    var body: some View {
        Form {
            Section(header: Text("Filter Options")) {
                Picker("Group", selection: $selectedGroup) {
                    Text("All Groups").tag(nil as String?)
                    ForEach(groups, id: \.id) { group in
                        Text(group.name).tag(group as GroupModel?)
                    }
                }
                
                if let selectedGroup = selectedGroup {
                    Picker("Paid by", selection: $selectedPaidByUserId) {
                        Text("Paid by - not selected").tag(nil as String?)
                        ForEach(selectedGroup.membersAsUsers, id: \.id) { member in
                            Text(member.fullName)
                                .tag(member.id as String?)
                        }
                    }
                    
                    Picker("Participant", selection: $selectedParticipantId) {
                        Text("All Participants").tag(nil as String?)
                        ForEach(selectedGroup.membersAsUsers, id: \.self) { member in
                            Text(member.fullName).tag(member.id as String?)
                        }
                    }
                }
                
                Picker("Category", selection: $selectedCategory) {
                    Text("All Categories").tag(nil as String?)
                    ForEach(categoryViewModel.categories, id: \.self) { category in
                        Text(category.name).tag(category as Category?)
                    }
                }
                
                Button(action: {
                    print("Filters submitted!")
                }) {
                    Text("Apply filters")
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                .padding()
                
            }
        }
        
        List(groups, id: \.id) { group in
            Text(group.name)
        }
        .onAppear {
            groups = groupViewModel.groups
        }
    }
}

struct ChartsView_Previews: PreviewProvider {
    static var previews: some View {
        ChartsView()
    }
}
