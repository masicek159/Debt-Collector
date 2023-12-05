//
//  GroupDetail.swift
//  Debt-Collector
//
//  Created by Martin Sir on 09.11.2023.
//

import SwiftUI

class Transaction: Hashable {
    var debtor: String
    var creditor: String
    var debt: Double
    
    init(debtor: String, creditor: String, debt: Double) {
        self.debtor = debtor
        self.creditor = creditor
        self.debt = debt
    }
    
    static func == (lhs: Transaction, rhs: Transaction) -> Bool {
        return lhs.debtor == rhs.debtor && lhs.creditor == rhs.creditor && lhs.debt == rhs.debt
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(debtor)
        hasher.combine(creditor)
        hasher.combine(debt)
    }
}

struct GroupDetail: View {
    @ObservedObject var groupViewModel = GroupViewModel()
    @State var showAddExpensePopUp = false
    @State var showEditExpensePopUp = false
    @State var showAddMemberPopUp = false
    @State var isMemberListExpanded = true
    @State var isExpenseListExpanded = true
    @State private var showAllExpenses = false
    @State private var showAllMembers = false
    @State private var showDeleteMemberAlert: Bool = false
    @State private var showDeleteExpenseAlert: Bool = false
    @State private var showEditExpenseAlert: Bool = false
    @State private var memberToDelete: GroupMember? = nil
    @State private var expenseToDelete: ExpenseModel? = nil
    @State private var expenseToEdit: ExpenseModel? = nil
    
    @State var participants: [Participant] = []
    
    @State var group: GroupModel
    @State var sharesNotSpecified: Bool = true
    @State var transactions: [Transaction] = []
    
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
                            ForEach(group.members.sorted(by: {$0.balance < $1.balance}).prefix(showAllMembers ? group.members.count : 3), id: \.self) { member in
                                HStack {
                                    Image(systemName: "person.fill")
                                        .font(.largeTitle)
                                        .foregroundColor(.purple)
                                    Text(member.fullName)
                                        .font(.headline)
                                    Spacer()
                                    let formattedBalance = String(format: "%.2f", member.balance)
                                    Text("Balance: \(formattedBalance)$")
                                        .font(.subheadline)
                                        .foregroundColor(member.balance >= 0 ? .green : .red)
                                }
                                .swipeActions {
                                    Button {
                                        memberToDelete = member
                                        showDeleteMemberAlert = true
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                    .tint(.red)
                                }
                                .alert(isPresented: $showDeleteMemberAlert) {
                                    if let innerMemberToDelete = memberToDelete, innerMemberToDelete.balance == 0 {
                                        return Alert(
                                            title: Text("Delete Member"),
                                            message: Text("Are you sure you want to delete \(innerMemberToDelete.fullName) from this group?"),
                                            primaryButton: .destructive(Text("Delete"), action: {
                                                do {
                                                    let groupManager = GroupManager.shared
//                                                    try groupManager.deleteMember(groupId: group.id, userId: innerMemberToDelete.memberId)
                                                } catch {
                                                    // Handle the error, e.g., display an error message
                                                    print("Error deleting member: \(error)")
                                                }
                                            }),
                                            secondaryButton: .cancel({
                                                memberToDelete = nil
                                            })
                                        )
                                    } else {
                                        return Alert(
                                            title: Text("Fail to delete member"),
                                            message: Text("You cannot delete user with non zero balance."),
                                            dismissButton: .default(Text("OK"), action: {
                                                showDeleteMemberAlert = false
                                                memberToDelete = nil
                                            })
                                        )
                                    }
                                }
                            }
                            
                            if group.members.count > 3 {
                                Button(action: {
                                    showAllMembers.toggle()
                                }) {
                                    Text(showAllMembers ? "Show Less" : "Show All")
                                }
                            }
                        }
                    }
                }
                .sheet(isPresented: $showAddMemberPopUp) {
                    NewGroupMemberView(showAddMemberPopUp: $showAddMemberPopUp, group: group)
                }
                
                Section(header: HStack {
                    Text("Expenses")
                    
                    Button(action: {
                        isExpenseListExpanded.toggle()
                    }) {
                        Image(systemName: isExpenseListExpanded ? "chevron.down" : "chevron.up")
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        participants = []
                        for user in group.membersAsUsers {
                            participants.append(Participant(userId: user.id, fullName: user.fullName))
                        }
                        showAddExpensePopUp = true
                    }) {
                        Image(systemName: "plus")
                    }
                }) {
                    if isExpenseListExpanded {
                        if group.expenses.isEmpty {
                            Text("Group does not have any expenses")
                        } else {
                            ForEach(group.expenses.prefix(showAllExpenses ? group.expenses.count : 3), id: \.id) { expense in
                                HStack{
                                    Text(expense.name)
                                    let formattedExpense = String(format: "%.2f", expense.amount)
                                    
                                    Text(formattedExpense)
                                }
                                .swipeActions {
                                    Button {
                                        self.expenseToEdit = expense
                                        showEditExpensePopUp = true
                                    } label: {
                                        Label("Edit", systemImage: "pencil")
                                    }
                                    .tint(.blue)
                                    
                                    Button {
                                        expenseToDelete = expense
                                        showDeleteExpenseAlert = true
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                    .tint(.red)
                                }
                                .alert(isPresented: $showDeleteExpenseAlert) {
                                    Alert(
                                        title: Text("Delete Expense"),
                                        message: Text("Are you sure you want to expense: \(expenseToDelete?.name ?? "") from this group?"),
                                        primaryButton: .destructive(Text("Delete"), action: {
                                            // TODO: delete expense from group + update balances in memebers
                                        }),
                                        secondaryButton: .cancel({
                                            expenseToDelete = nil
                                        })
                                    )
                                    
                                }
                                .alert(isPresented: $showEditExpenseAlert) {
                                    Alert(
                                        title: Text("Success"),
                                        message: Text("Expense was successfully deleted"),
                                        dismissButton: .default(Text("OK"), action: {
                                            showEditExpenseAlert = false
                                        })
                                    )
                                    
                                }
                            }
                            
                            if group.expenses.count > 3 {
                                Button(action: {
                                    showAllExpenses.toggle()
                                }) {
                                    Text(showAllExpenses ? "Show Less" : "Show All")
                                }
                            }
                        }
                    }
                }
                .sheet(isPresented: $showAddExpensePopUp) {
                    AddExpenseInGroupView(group: group, showAddOrEditExpensePopUp: $showAddExpensePopUp, mode: ExpenseViewModeEnum.add, existingExpense: $expenseToEdit, participants: $participants, sharesNotSpecified: $sharesNotSpecified)
                }
                .sheet(isPresented: $showEditExpensePopUp) {
                    AddExpenseInGroupView(group: group, showAddOrEditExpensePopUp: $showEditExpensePopUp, mode: ExpenseViewModeEnum.update, existingExpense: $expenseToEdit, participants: $participants, sharesNotSpecified: $sharesNotSpecified)
                }
                .task {
                    await groupViewModel.getGroups()
                }
                
                Section("Debts") {
                    if transactions.isEmpty{
                        Text("There are no any debts")
                    } else {
                        ForEach(transactions, id: \.self) { transaction in
                            GeometryReader { geometry in
                                HStack {
                                    Text(transaction.debtor)
                                        .frame(width: geometry.size.width / 3, alignment: .leading)
                                    
                                    Spacer()
                                    
                                    VStack {
                                        Image(systemName: "arrow.right")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 100)
                                            .foregroundColor(.blue)
                                        
                                        Text(String(format: "$%.2f", transaction.debt))
                                            .font(.footnote)
                                    }
                                    
                                    Spacer()
                                    
                                    Text(transaction.creditor)
                                        .frame(width: geometry.size.width / 3, alignment: .trailing)
                                }
                            }
                        }
                    }
                }
                .task {
                    calculateDebt()
                }
                
            }
        }
    }
    
    private func calculateDebt() {
        var netAmounts: [String: Double] = [:]
        transactions = []
        
        for member in group.members {
            if member.balance != 0 {
                netAmounts[member.fullName] = member.balance
            }
        }
        while netAmounts.count > 1 {
            if let (debtor, debt) = netAmounts.min(by: { $0.value < $1.value }) {
                if let (creditor, credit) = netAmounts.max(by: { $0.value < $1.value }) {
                    netAmounts[creditor] = credit + debt
                    netAmounts.removeValue(forKey: debtor)
                    transactions.append(Transaction(debtor: debtor, creditor: creditor, debt: -debt))
                } else {
                    break
                }
            } else {
                break
            }
        }
    }
}



