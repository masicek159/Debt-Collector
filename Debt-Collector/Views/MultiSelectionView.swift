//
//  MultiSelectorView.swift
//  Debt-Collector
//
//  Created by Martin Sir on 24.11.2023.
//

import SwiftUI

struct MultiSelectionView: View {
    @Binding var totalAmount: Double
    @Binding var participants: [Participant]
    
    @State var isPopupVisibleForShares = false
    @State var isPopupVisibleForAmounts = false
    @State var shareValues: [Double] = []
    @State var amounts: [Double] = []


    @Binding var selectedParticipants: [Participant]
    @Binding var sharesNotSpecified: Bool

    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    isPopupVisibleForShares = true
                    sharesNotSpecified = false
                }) {
                    Text("Shares")
                        .padding()
                        .foregroundColor(.white)
                }
                .background(Color.blue)
                .cornerRadius(8)
                .sheet(isPresented: $isPopupVisibleForShares) {
                    // PopupView for Shares
                    PopupViewShares(shareValues: $shareValues, selectedParticipants: $selectedParticipants) {
                        
                        let totalShares: Double = shareValues.reduce(0, +)
                        for idx in 0..<selectedParticipants.count {
                            selectedParticipants[idx].share = shareValues[idx]
                            selectedParticipants[idx].amountToPay = Double(totalAmount / totalShares) * selectedParticipants[idx].share

                        }
                        
                        isPopupVisibleForShares = false
                        
                    }
                }

                Button(action: {
                    isPopupVisibleForAmounts = true
                    sharesNotSpecified = false
                }) {
                    Text("Amount")
                        .padding()
                        .foregroundColor(.white)
                }
                .background(Color.blue)
                .cornerRadius(8)
                .sheet(isPresented: $isPopupVisibleForAmounts) {
                    PopupViewAmounts(amounts: $amounts, selectedParticipants: $selectedParticipants) {
                        
                        let total: Double = amounts.reduce(0, +)

                        for idx in 0..<selectedParticipants.count {
                            selectedParticipants[idx].amountToPay = amounts[idx]
                            selectedParticipants[idx].share = Double(participants[idx].amountToPay / totalAmount) * total
                        }
                        
                        isPopupVisibleForAmounts = false
                    }
                }

            }
            .padding()
            .frame(maxWidth: .infinity)
            
            List {
                ForEach(participants) { participant in
                    Button(action: { toggleSelection(participant: participant) }) {
                        HStack {
                            Text(participant.fullName)
                            Spacer()
                            if selectedParticipants.contains(where: { $0.userId == participant.userId }) {
                                Image(systemName: "checkmark").foregroundColor(.accentColor)
                            }
                        }
                    }.tag(participant.id)
                }
            }
            
        }
        .listStyle(GroupedListStyle())
    }


    private func toggleSelection(participant: Participant) {
        if let existingIndex = selectedParticipants.firstIndex(where: { $0.id == participant.id }) {
            selectedParticipants.remove(at: existingIndex)
            shareValues.remove(at: existingIndex)
            amounts.remove(at: existingIndex)
        } else {
            selectedParticipants.append(participant)
            shareValues.append(1)
            amounts.append(0)
        }
    }
}
