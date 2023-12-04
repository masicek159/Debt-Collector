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
    @EnvironmentObject var categoryViewModel: CategoryViewModel
    
    @State var name: String = ""
    @State var amount: Double = 0.0
    @State var uploadingExpense = false
    @State var group: GroupModel? = nil
    @State var category: Category? = nil
    @State var expenseCurrency: String = ""
    @State var paidBy: User? = AuthViewModel.shared.currentUser
    @State var participants: Set<User> = []
    @State var expenseAdded = false
    
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
                            participants = Set(Array(newGroup?.members ?? []))
                            expenseCurrency = newGroup?.currency ?? "USD"
                        }
                        
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
                            ForEach(Array(group?.members ?? []), id: \.id) { user in
                                Text(user.fullName)
                                    .tag(user as User?)
                            }
                        }
                        .pickerStyle(.menu)
                        
                        MultiSelector<Text, User>(
                            label: Text("For whom"),
                            options: Array(group?.members ?? []),
                            optionToString: { $0.fullName },
                            selected: $participants
                        )
                        
                        Button(action: {
                            Task {
                                if let group = group, let paidBy = paidBy {
                                    uploadingExpense = true
                                    try await expenseViewModel.addExpense(name: name, amount: amount, category: category, currency: expenseCurrency, groupId: group.id, paidBy: paidBy, participants: Array(participants))
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
                    category = categoryViewModel.categories.filter{$0.name == "General"}.first
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
