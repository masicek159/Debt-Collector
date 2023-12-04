//
//  MultiSelector.swift
//  Debt-Collector
//
//  Created by Martin Sir on 24.11.2023.
//

import SwiftUI

struct MultiSelector: View {
    var totalAmount: Binding<Double>
    var participants: Binding<[Participant]>
    var selectedParticipants: Binding<[Participant]>

    private var formattedSelectedListString: String {
        ListFormatter.localizedString(byJoining: selectedParticipants.wrappedValue.map { $0.fullName })
    }

    var body: some View {
        NavigationLink(destination: multiSelectionView()) {
            HStack {
                Text("For whom")
                Spacer()
                
                Group {
                    if participants.count == selectedParticipants.wrappedValue.count {
                        Text("All members")
                    } else {
                        Text(formattedSelectedListString)
                    }
                }
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.trailing)
            }
        }
    }

    private func multiSelectionView() -> some View {
        MultiSelectionView(
            totalAmount: totalAmount,
            participants: participants,
            selectedParticipants: selectedParticipants
        )
    }
}
