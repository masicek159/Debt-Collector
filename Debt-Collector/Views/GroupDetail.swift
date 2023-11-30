//
//  GroupDetail.swift
//  Debt-Collector
//
//  Created by Martin Sir on 09.11.2023.
//

import SwiftUI

struct GroupDetail: View {
    @ObservedObject var groupViewModel = GroupViewModel()
    
    var group: GroupModel
    @State var expenses: [ExpenseModel] = []
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    HStack {
                        if let imageData = group.image, let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 72, height: 72)
                        } else {
                            // TODO: tmp obrazek postavy
                            Image(systemName: "person.3")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 72, height: 72)
                        }
                        
                        Spacer()
                        
                        VStack {
                            Text(group.name)
                            
                            Text(group.currency)
                                .font(.footnote)
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                Section("Members") {
                    ForEach(groupViewModel.members, id: \.self) { member in
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
                    
                    NavigationLink(destination: NewGroupMemberView(group: group)) {
                        Text("Add Member")
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                    .navigationBarBackButtonHidden(true)
                }
                .onAppear {
                    groupViewModel.getMembers(groupId: group.id)
                }
                Section("Expenses") {
                    ForEach(expenses, id: \.id) { expense in
                        HStack{
                            Text(expense.name)
                            
                            Text("\(expense.amount)")
                        }
                    }
                }
            }
        }
        .onAppear {
            Task {
                expenses = try await groupViewModel.getExpenses(groupId: group.id)
            }
        }
    }
}


