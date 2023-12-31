//
//  AddExpenseInGroupView.swift
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
    @Binding var showAddOrEditExpensePopUp: Bool
    var mode: ExpenseViewModeEnum
    @Binding var existingExpense: ExpenseModel?
    
    @State var name: String = ""
    @State var amount: Double = 0.0
    @State var uploadingExpense = false
    @State var category: Category? = nil
    @State var expenseCurrency: String = "USD"
    @State var paidBy: User? = AuthViewModel.shared.currentUser
    @State var expenseAdded = false
    @State var dateCreated: Date = Date()
    @State var selectedParticipants: [Participant] = []
    
    @Binding var participants: [Participant]
    @Binding var sharesNotSpecified: Bool
    
    let decimalFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
    
    var body: some View {
        NavigationView {
            Form {
                Section() {
                    TextField("Name", text: $name)
                    Picker("Category", selection: $category) {
                        ForEach(categoryViewModel.categories, id: \.id) { category in
                            Text(category.name).tag(category as Category?)
                        }
                    }
                    .pickerStyle(.menu)
                    .accentColor(.purple)
                    TextField("Amount", value: $amount, formatter: decimalFormatter)
                        .keyboardType(.numberPad)
                    Picker("Select Currency", selection: $expenseCurrency) {
                        ForEach(CurrenciesHelper.shared.currencies, id: \.self) { currency in
                            Text(currency).tag(currency)
                        }
                    }
                    .pickerStyle(.menu)
                    .accentColor(.purple)
                    Picker("Select Who Paid", selection: $paidBy) {
                        ForEach(group.membersAsUsers, id: \.id) { user in
                            Text(user.fullName).tag(user as User?)
                        }
                    }
                    .pickerStyle(.menu)
                    .accentColor(.purple)
                    MultiSelector(
                        totalAmount: $amount,
                        participants: $participants,
                        selectedParticipants: $selectedParticipants,
                        sharesNotSpecified: $sharesNotSpecified
                    )
                    DatePicker("Date", selection: $dateCreated, displayedComponents: [.date])
                }
                
                Section {
                    Button(action: {
                        Task {
                            if let paidBy = paidBy {
                                uploadingExpense = true
                                
                                var total: Double = 0
                                var counter: Double = 0
                                for participant in selectedParticipants {
                                    counter += 1
                                }
                                print(counter)
                                var toPay = amount/counter
                                print(toPay)
                                for participant in selectedParticipants {
                                    participant.amountToPay = 0
                                    participant.amountToPay += toPay
                                    print(toPay)
                                    try await UserManager.shared.updateFriendBalance(userId: paidBy.id, friendId: participant.userId, amount: -toPay)
                                    try await UserManager.shared.updateFriendBalance(userId: participant.userId, friendId: paidBy.id, amount: toPay)
                                    print(participant.amountToPay)
                                }
                                
                                if mode == .add {
                                    try await expenseViewModel.addExpense(
                                        name: name,
                                        amount: amount,
                                        category: category,
                                        currency: expenseCurrency,
                                        groupId: group.id,
                                        paidBy: paidBy,
                                        participants: selectedParticipants,
                                        dateCreated: dateCreated
                                    )
                                } else {
                                    if let existingExpense = existingExpense {
                                        try await expenseViewModel.editExpense(
                                            previousExpense: existingExpense,
                                            expenseId: existingExpense.id,
                                            name: name,
                                            amount: amount,
                                            category: category,
                                            currency: expenseCurrency,
                                            groupId: group.id,
                                            paidBy: paidBy,
                                            participants: selectedParticipants,
                                            dateCreated: dateCreated
                                            )
                                        
                                    }
                                }
                                
                                uploadingExpense = false
                                showAddOrEditExpensePopUp = false
                            }
                        }
                    }) {
                        if mode == .add {
                            Text("Add Expense")
                                .font(.title2)
                                .foregroundColor(.purple)
                        } else {
                            Text("Update Expense")
                                .font(.title2)
                                .foregroundColor(.purple)
                        }
                    }
                    .disabled(uploadingExpense)
                }
            }
            .padding()
            .navigationBarTitle(mode == .add ? "Add Expense" : "Update Expense", displayMode: .inline)
            
            .navigationBarItems(trailing: Button(action: {
                showAddOrEditExpensePopUp = false
            }) {
                Text("Cancel")
                    .foregroundColor(.purple)
            })
            
            .task {
                selectedParticipants = participants
                if mode == .update, let existingExpense = existingExpense {
                    name = existingExpense.name
                    amount = existingExpense.amount
                    category = existingExpense.category
                    expenseCurrency = existingExpense.currency
                    paidBy = existingExpense.paidBy
                    selectedParticipants = existingExpense.participants
                } else {
                    category = categoryViewModel.categories.first
                    paidBy = AuthViewModel.shared.currentUser
                    await fetchDataAndWriteToFile()
                }
            }
        }
    }
}
