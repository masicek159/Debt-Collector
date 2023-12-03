//
//  AddExpenseView.swift
//  Debt-Collector
//
//  Created by user248815 on 10/19/23.
//

import SwiftUI

struct AddExpenseView: View {
    @ObservedObject var groupViewModel = GroupViewModel()
    @ObservedObject var expenseViewModel = ExpenseViewModel()
    
    @State var name: String = ""
    @State var amount: Double = 0.0
    @State var uploadingExpense = false
    @State var group: GroupModel? = nil
    @State var category: String = ""
    @State var expenseCurrency: String = ""
    @State var paidBy: User? = AuthViewModel.shared.currentUser
    @State var selectedParticipants: [Participant] = []
    @State var expenseAdded = false
    @State var participants: [Participant] = []

    
    init() {
        group = groupViewModel.groups.first
        self._expenseCurrency = State(initialValue: group?.currency ?? "USD")
    }
    
    let decimalFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
    
    var body: some View {
        Group {
            if expenseAdded {
                VStack {
                    Text("Expense was added")
                    
                    Button(action: {
                        expenseAdded = false
                    }) {
                        Text("Add another expense")
                    }
                }
            } else {
                NavigationView{
                    Form {
                        Picker("Select Group", selection: $group) {
                            ForEach(groupViewModel.groups, id: \.id) { group in
                                Text(group.name).tag(group as GroupModel?)
                            }
                        }
                        .pickerStyle(.menu)
                        .onChange(of: group) { newGroup in
                            paidBy = AuthViewModel.shared.currentUser
                            participants = []
                            for member in newGroup?.members ?? [] {
                                participants.append(Participant(userId: member.id, fullName: member.fullName))
                            }
                            expenseCurrency = newGroup?.currency ?? "USD"
                        }
                        
                        TextField("Name", text: $name)
                        
                        TextField("Category", text: $category)
                        
                        TextField("Amount", value: $amount, formatter: decimalFormatter)
                        
                        Picker("Select Currency", selection: $expenseCurrency) {
                            ForEach(CurrenciesHelper.shared.currencies, id: \.self) { currency in
                                Text(currency).tag(currency)
                            }
                        }
                        .pickerStyle(.menu)
                        
                        Picker("Select Who Paid", selection: $paidBy) {
                            ForEach(Array(group?.members ?? []), id: \.id) { user in
                                Text(user.fullName)
                                    .tag(user as User?)
                            }
                        }
                        .pickerStyle(.menu)
                        
                        MultiSelector(
                            totalAmount: amount,
                            participants: participants,
                            selectedParticipants: $selectedParticipants
                        )
                        
                        Button(action: {
                            Task {
                                if let group = group, let paidBy = paidBy {
                                    uploadingExpense = true
                                    try await expenseViewModel.addExpense(name: name, amount: amount, category: category, currency: expenseCurrency, groupId: group.id, paidBy: paidBy, participants: selectedParticipants)
                                    uploadingExpense = false
                                    expenseAdded = true
                                }
                            }
                        }) {
                            Text("Add Expense")
                        }
                    }
                    .disabled(uploadingExpense)
                }
                .task {
                    groupViewModel.getGroups()
                    for member in group?.members ?? [] {
                        participants.append(Participant(userId: member.id, fullName: member.fullName))
                    }
                }
            }
        }
    }
}

struct AddExpenseView_Previews: PreviewProvider {
    static var previews: some View {
        AddExpenseView()
    }
}
