//
//  ChartsView.swift
//  Debt-Collector
//
//  Created by user248815 on 10/19/23.
//

import SwiftUI
import SwiftUICharts

struct ChartsView: View {
    @EnvironmentObject var groupViewModel: GroupViewModel
    @EnvironmentObject var categoryViewModel: CategoryViewModel
    @State var groups: [GroupModel] = []
    @State var selectedGroup: GroupModel? = nil
    @State var selectedParticipantId: String? = nil
    @State var selectedPaidByUserId: String? = nil
    @State var selectedCategory: Category? = nil
    @State var filteredExpenses: [ExpenseModel] = []
    
    var body: some View {
        Form {
            Section(header: Text("Filter Options")) {
                Picker("Group", selection: $selectedGroup) {
                    Text("All Groups").tag(nil as String?)
                    ForEach(groupViewModel.groups, id: \.id) { group in
                        Text(group.name).tag(group as GroupModel?)
                    }
                }
                .task {
                    groups = groupViewModel.groups
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
                
                Button(action: {
                    filterExpenses()
                }) {
                    Text("Apply filters")
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                .padding()
                
            }
        }
        
        LineChartView(
            data: extractChartData(from: filteredExpenses),
            title: "Expense Chart",
            legend: "Expenses",
            style: ChartStyle(
                backgroundColor: .white,
                accentColor: .blue,
                gradientColor: GradientColor(start: .blue, end: .red),
                textColor: .black,
                legendTextColor: .green,
                dropShadowColor: .gray
            )
        )
        .padding()
        
        List(groups, id: \.id) { group in
            Text(group.name)
        }
    }
    
    private func filterExpenses() {
        // TODO: filter expenses
    }
    
    private func extractChartData(from expenses: [ExpenseModel]) -> [Double] {
            // Sort expenses by creation date
//            let sortedExpenses = expenses.sorted(by: { $0.creationDate < $1.creationDate })

        
            var chartData: [Double] = []
            for expense in expenses {
                chartData.append(expense.amount)
            }

            return chartData
        }
}

struct ChartsView_Previews: PreviewProvider {
    static var previews: some View {
        ChartsView()
    }
}
