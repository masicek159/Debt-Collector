//
//  AddExpenseView.swift
//  Debt-Collector
//
//  Created by user248815 on 10/19/23.
//

import SwiftUI

struct AddExpenseInGroupView: View {
    @ObservedObject var groupViewModel = GroupViewModel()
    @ObservedObject var expenseViewModel = ExpenseViewModel()
    var group: GroupModel
    @Binding var showAddExpensePopUp: Bool
    
    @State var name: String = ""
    @State var amount: Double = 0.0
    @State var uploadingExpense = false
    @State var category: String = ""
    @State var expenseCurrency: String = ""
    @State var paidBy: User? = AuthViewModel.shared.currentUser
    @State var selectedParticipants: [Participant] = []
    @State var expenseAdded = false
    @State var participants: [Participant] = []
    
    let decimalFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
    
    var body: some View {
        Section (header: HStack {
            Text("Add an expense")
                .font(.title)
            
            Spacer()
            
            Button(action: {
                showAddExpensePopUp = false
            }) {
                Text("Cancel")
            }
        }) {
            Form {
                Text(group.name)
                
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
                    ForEach(Array(group.members), id: \.id) { user in
                        Text(user.fullName)
                            .tag(user as User?)
                    }
                }
                .pickerStyle(.menu)
                
                MultiSelector(
                    totalAmount: $amount,
                    participants: participants,
                    selectedParticipants: $selectedParticipants
                )
                
                Button(action: {
                    Task {
                        if let paidBy = paidBy {
                            uploadingExpense = true
                            
                            var total: Double = 0
                            for participant in selectedParticipants {
                                total += participant.amountToPay
                            }
                            
                            if total != amount {
                                // change the totalAmounts
                                amount = total
                            }
                            try await expenseViewModel.addExpense(name: name, amount: amount, category: category, currency: expenseCurrency, groupId: group.id, paidBy: paidBy, participants: Array(participants))
                            uploadingExpense = false
                            showAddExpensePopUp = false
                        }
                    }
                }) {
                    Text("Add Expense")
                }
            }
            .disabled(uploadingExpense)
        }
        .padding()
        .task {
            groupViewModel.getGroups()
            expenseCurrency = group.currency
        }
    }
}
