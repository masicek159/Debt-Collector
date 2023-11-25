//
//  AddExpenseView.swift
//  Debt-Collector
//
//  Created by user248815 on 10/19/23.
//

import SwiftUI

@MainActor
final class ExpenseViewModel: ObservableObject {
    @Published private(set) var expenses: [GroupModel] = []
    
    func addExpense(name: String, amount: Double, category: String, currency: String, groupId: String, paidBy: User, participants: [User]) async throws {
        try await ExpenseManager.shared.uploadExpense(name: name, amount: amount, category: category, currency: currency, groupId: groupId, paidBy: paidBy, participants: participants)
    }
}

struct AddExpenseView: View {
    @ObservedObject var groupViewModel = GroupsViewModel()
    @ObservedObject var expenseViewModel = ExpenseViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @State var name: String = ""
    @State var amount: Double = 0.0
    @State var uploadingExpense = false
    @State var group: GroupModel? = nil
    @State var category: String = ""
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
        if expenseAdded {
            Text("Expense was added")
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
                        participants = Set(Array(newGroup?.members.map { $0.0 } ?? []))
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
                        ForEach(Array(group?.members ?? [:]), id: \.key) { (user, intValue) in
                            Text(user.fullName)
                                .tag(user as User?)
                        }
                    }
                    .pickerStyle(.menu)
                    
                    MultiSelector<Text, User>(
                        label: Text("For whom"),
                        options: Array(group?.members.map { $0.0 } ?? []),
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
            }
        }
    }
}
