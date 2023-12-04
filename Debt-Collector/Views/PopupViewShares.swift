import SwiftUI

struct PopupViewShares: View {
    @Binding var shareValues: [Double]
    @Binding var selectedParticipants: [Participant]
    
    let actionHandler: () -> Void
    
    let decimalFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
    
    var body: some View {
        VStack {
            Text("Selected members")
                .font(.title)
                .padding()
            
            List {
                ForEach(0..<selectedParticipants.count, id: \.self) { index in
                    HStack {
                        Text(selectedParticipants[index].fullName)
                        Spacer()
                        TextField("", value: $shareValues[index], formatter: decimalFormatter)
                    }
                }
            }
            
            
            Button(action: {
                actionHandler()
            }) {
                Text("Done")
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            .padding()
        }
        .background(Color.white)
        .cornerRadius(10)
        .padding()
    }
}
