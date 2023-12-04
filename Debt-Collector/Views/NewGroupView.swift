//
//  NewGroupView.swift
//  Debt-Collector
//
//  Created by Martin Sir on 05.11.2023.
//

import SwiftUI

extension UIColor {
    class func color(data: Data) -> UIColor {
        try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as! UIColor
    }
    func encode() -> Data {
        try! NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false)
    }
}

struct NewGroupView: View {
    @ObservedObject var viewModel: GroupViewModel
    @Binding var showPopup: Bool
    @State var uploadingGroup = false
    
    @State private var groupName = ""
    @State private var groupCurrency = ""
    @State private var groupImage = ""
    
    @State private var selectedColor: Color = Color.blue

    init(viewModel: GroupViewModel, showPopup: Binding<Bool>) {
        self.viewModel = viewModel
        self._showPopup = showPopup
        self._groupCurrency = State(initialValue: CurrenciesHelper.shared.currencies.first ?? "USD")
    }
    
    var body: some View {
        NavigationView{
            Form {
                Section(header: Text("Group Information")) {
                    TextField("Name", text: $groupName)
                    
                    Picker("Select Currency", selection: $groupCurrency) {
                        ForEach(CurrenciesHelper.shared.currencies, id: \.self) { currency in
                            Text(currency)
                                .tag(currency)
                        }
                    }
                    .pickerStyle(.menu)
                    .accentColor(.purple)
                }
                
                Section(header: Text("Group Color")) {
                    ColorPicker("Select a color", selection: $selectedColor)
                }
                
                VStack {
                    Spacer()
                    Button(action: {
                        Task {
                            uploadingGroup = true
                            try await viewModel.addGroup(name: groupName, currency: groupCurrency, color: UIColor(selectedColor).encode())
                            showPopup = false
                            uploadingGroup = false
                            await viewModel.getGroups()
                        }
                    }) {
                        Text("Create Group")
                            .font(.title2)
                            .foregroundColor(.purple)
                    }
                    Spacer()
                }
                
            }
            .disabled(uploadingGroup)
            .navigationBarTitle("New Group")
        }
    }
        

}

struct NewGroupView_Previews: PreviewProvider {
    static var previews: some View {
    NewGroupView(viewModel: GroupViewModel(), showPopup: .constant(false))
    }
}
