//
//  GroupDetail.swift
//  Debt-Collector
//
//  Created by Martin Sir on 09.11.2023.
//

import SwiftUI

struct GroupDetail: View {
    @ObservedObject var viewModel = GroupsViewModel()
    
    var group: GroupModel
    @State var expenses: [ExpenseModel] = []
    
    var body: some View {
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
        .onAppear {
            Task {
                expenses = try await viewModel.getExpenses(groupId: group.id)
            }
        }
    }
}

struct GroupDetail_Previews: PreviewProvider {
    static var previews: some View {
        GroupDetail(group: GroupModel(id: "1", name: "Group name", currency: "USD", image: nil, owner: User(id: "ss", email: "Friend1@gmail.com", fullName: "Friend 1")))
    }
}

