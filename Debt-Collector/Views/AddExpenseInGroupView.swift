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
    @EnvironmentObject var categoryViewModel: CategoryViewModel
    var group: GroupModel
    @Binding var showAddExpensePopUp: Bool
    
    @State var name: String = ""
    @State var amount: Double = 0.0
    @State var uploadingExpense = false
    @State var category: Category? = nil
    @State var expenseCurrency: String = "USD"
    @State var paidBy: User? = AuthViewModel.shared.currentUser
    @State var selectedParticipants: [Participant] = []
    @State var expenseAdded = false
    @State var participants: [Participant] = []
    @State var dateCreated: Date = Date()
    
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
                
                Picker("Category", selection: $category) {
                    ForEach(categoryViewModel.categories , id: \.id) { category in
                        Text(category.name)
                            .tag(category as Category?)
                    }
                }
                .pickerStyle(.menu)
                
                TextField("Amount", value: $amount, formatter: decimalFormatter)
                
                Picker("Select Currency", selection: $expenseCurrency) {
                    ForEach(CurrenciesHelper.shared.currencies, id: \.self) { currency in
                        Text(currency).tag(currency)
                    }
                }
                .pickerStyle(.menu)
                
                Picker("Select Who Paid", selection: $paidBy) {
                    ForEach(group.membersAsUsers, id: \.id) { user in
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
                
                DatePicker(
                    "Date",
                    selection: $dateCreated,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                
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
                            try await expenseViewModel.addExpense(name: name, amount: amount, category: category, currency: expenseCurrency, groupId: group.id, paidBy: paidBy, participants: Array(participants), dateCreated: dateCreated)
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
            category = categoryViewModel.categories.filter{$0.name == "General"}.first
            paidBy = AuthViewModel.shared.currentUser
            await groupViewModel.getGroups()
            expenseCurrency = group.currency
        }
    }
}
