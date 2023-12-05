//
//  ChartsView.swift
//  Debt-Collector
//
//  Created by user248815 on 10/19/23.
//

import SwiftUI
import SwiftUICharts
import Charts

struct dataPoint: Identifiable {
    var id = UUID()
    var date: Date
    var amount: Double
}

struct ChartsView: View {
    @EnvironmentObject var groupViewModel: GroupViewModel
    @EnvironmentObject var categoryViewModel: CategoryViewModel
    @State var selectedGroup: GroupModel? = nil
    @State var selectedParticipantId: String? = nil
    @State var selectedParticipant: Participant? = nil
    @State var selectedPaidByUserId: String? = nil
    @State var selectedCategory: Category? = nil
    @State var filteredExpenses: [ExpenseModel] = []
    @State var selectedFrequency: FrequencyEnum? = nil
    @State var points: [dataPoint] = []
    
    var body: some View {
        VStack {
            Form {
                Section(header: Text("Filter Options")) {
                    Picker("Group", selection: $selectedGroup) {
                        Text("All Groups").tag(nil as String?)
                        ForEach(groupViewModel.groups, id: \.id) { group in
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
                        .task {
                            await categoryViewModel.loadCategories()
                        }
                    }
                    
                    Picker("Frequency", selection: $selectedFrequency) {
                        Text("None").tag(nil as String?)
                        ForEach(FrequencyEnum.allCases, id: \.self) { frequency in
                            Text(frequency.rawValue).tag(frequency as FrequencyEnum?)
                        }
                    }
                    
                    HStack {
                        Button(action: {}) {
                            Text("Apply filters")
                        }
                        .onTapGesture {
                            filterExpenses()
                            extractChartData(from: filteredExpenses)
                        }
                        
                        Spacer()
                        
                        Divider().background(Color.black)
                        
                        Spacer()
                        
                        Button(action: {}) {
                            Text("Remove filters")
                        }
                        .onTapGesture {
                            resetFilters()
                            filterExpenses()
                            extractChartData(from: filteredExpenses)
                        }
                    }
                }
            }
            
            Section{
                if !filteredExpenses.isEmpty {
                    Chart(points) {
                        BarMark(
                            x: .value("Date", $0.date),
                            y: .value("Amount", $0.amount)
                        )
                    }
                }
            }
            .padding(50)
        }
    }
    
    private func resetFilters() {
        selectedGroup = nil
        selectedCategory = nil
        selectedPaidByUserId = nil
        selectedParticipantId = nil
        selectedFrequency = nil
    }
    
    private func filterExpenses() {
        if let selectedGroup = selectedGroup {
            filteredExpenses = selectedGroup.expenses
        } else {
            filteredExpenses = []
            for group in groupViewModel.groups {
                filteredExpenses += group.expenses
            }
        }
        
        if let selectedCategory = selectedCategory {
            filteredExpenses = filteredExpenses.filter {
                $0.category == selectedCategory
            }
        }
        
        if let selectedPaidByUserId = selectedPaidByUserId {
            filteredExpenses = filteredExpenses.filter {
                $0.paidBy.id == selectedPaidByUserId
            }
        }
        
        if let selectedParticipantId = selectedParticipantId {
            filteredExpenses = filteredExpenses.filter {
                !$0.participants.filter{ $0.userId == selectedParticipantId}.isEmpty
            }
        }
    }
    
    private func extractChartData(from expenses: [ExpenseModel]) {
        let sortedExpenses = filteredExpenses.sorted(by: { $0.dateCreated < $1.dateCreated })
        
        if let selectedFrequency = selectedFrequency {
            let groupedExpenses: [Date: [ExpenseModel]] = Dictionary(grouping: sortedExpenses) { expense in
                switch selectedFrequency {
                case .hourly:
                    return Calendar.current.date(bySettingHour: Calendar.current.component(.hour, from: expense.dateCreated), minute: 0, second: 0, of: expense.dateCreated) ?? expense.dateCreated
                case .daily:
                    return Calendar.current.startOfDay(for: expense.dateCreated)
                case .monthly:
                    return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: expense.dateCreated)) ?? expense.dateCreated
                }
            }
            
            // Calculate sum of amounts within each interval
            var dataPoints: [dataPoint] = []
            
            for (interval, expensesInInterval) in groupedExpenses {
                var totalAmount = 0.0
                if let selectedParticipantId = selectedParticipantId {
                    totalAmount = expensesInInterval.reduce(0) { $0 + ($1.participants.filter{$0.userId == selectedParticipantId}.first?.amountToPay ?? 0) }
                } else {
                    totalAmount = expensesInInterval.reduce(0) { $0 + $1.amount }
                }
                let dataPoint = dataPoint(date: interval, amount: totalAmount)
                dataPoints.append(dataPoint)
            }
            points = dataPoints
        } else {
            var dataPoints: [dataPoint] = []
            for filteredExpense in filteredExpenses {
                dataPoints.append(dataPoint(date: filteredExpense.dateCreated, amount: filteredExpense.amount))
            }
            points = dataPoints
        }
    }
}

struct ChartsView_Previews: PreviewProvider {
    static var previews: some View {
        ChartsView()
    }
}
