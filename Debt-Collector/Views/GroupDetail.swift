//
//  GroupDetail.swift
//  Debt-Collector
//
//  Created by Martin Sir on 09.11.2023.
//

import SwiftUI

struct GroupDetail: View {
    @ObservedObject var groupViewModel = GroupViewModel()
    @State var showAddExpensePopUp = false
    @State var showAddMemberPopUp = false
    @State var isMemberListExpanded = true
    @State var isExpenseListExpanded = true
    
    @State var group: GroupModel
    @State var expenses: [ExpenseModel] = []
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    HStack {
                        Image(systemName: "person.3")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 72, height: 72)
                        
                        
                        Spacer()
                        
                        VStack {
                            Text(group.name)
                            
                            Text(group.currency)
                                .font(.footnote)
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                Section(header: HStack {
                    Text("Members")
                    
                    Button(action: {
                        isMemberListExpanded.toggle()
                    }) {
                        Image(systemName: isMemberListExpanded ? "chevron.down" : "chevron.up")
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        showAddMemberPopUp = true
                    }) {
                        Image(systemName: "plus")
                    }
                }) {
                    if isMemberListExpanded {
                        if group.members.isEmpty {
                            Text("Group does not have any members")
                        } else {
                            ForEach(group.members, id: \.self) { member in
                                HStack {
                                    Image(systemName: "person.fill")
                                        .font(.largeTitle)
                                        .foregroundColor(.purple)
                                    Text(member.fullName)
                                        .font(.headline)
                                    Spacer()
                                    Text("Balance: \(member.balance)$")
                                        .font(.subheadline)
                                        .foregroundColor(member.balance >= 0 ? .green : .red)
                                }
                            }
                        }
                    }
                }
                .sheet(isPresented: $showAddMemberPopUp) {
                    NewGroupMemberView(showAddMemberPopUp: $showAddMemberPopUp, group: group)
                }
                
                
                Section(header: HStack {
                    Text("Expeneses")
                    
                    Button(action: {
                        isExpenseListExpanded.toggle()
                    }) {
                        Image(systemName: isExpenseListExpanded ? "chevron.down" : "chevron.up")
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        showAddExpensePopUp = true
                    }) {
                        Image(systemName: "plus")
                    }
                }) {
                    if isExpenseListExpanded {
                        if expenses.isEmpty {
                            Text("Group does not have any expenses")
                        } else {
                            ForEach(expenses, id: \.id) { expense in
                                HStack{
                                    Text(expense.name)
                                    
                                    Text("\(expense.amount)")
                                }
                            }
                        }
                    }
                }
                .sheet(isPresented: $showAddExpensePopUp) {
                    AddExpenseInGroupView(group: group, showAddExpensePopUp: $showAddExpensePopUp)
                }
            }
        }
        .onAppear {
                    Task {
                        do {
                            let groupMembers = try await groupViewModel.getMembers(groupId: group.id)
                            let users = try await UserManager.shared.getUsersForGroupMembers(groupMembers: groupMembers)
                            group.members = users
                            
                            // Now you have a GroupModel with user details for members
                            // You can use groupWithUsers for your UI or wherever needed
                        } catch {
                            print("Error fetching group members or expenses: \(error)")
                        }
                    }
                }
    }
}



