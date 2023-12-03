//
//  MultiSelectorView.swift
//  Debt-Collector
//
//  Created by Martin Sir on 24.11.2023.
//

import SwiftUI

struct MultiSelectionView: View {
    let totalAmount: Double
    let participants: [Participant]
    
    @State var isPopupVisibleForShares = false
    @State var isPopupVisibleForPercentages = false
    @State var isPopupVisibleForAmounts = false
    @State var shareValues: [Double] = []


    @Binding var selectedParticipants: [Participant]

    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    isPopupVisibleForShares = true
                }) {
                    Text("Shares")
                        .padding()
                        .foregroundColor(.white)
                }
                .background(Color.blue)
                .cornerRadius(8)
                .sheet(isPresented: $isPopupVisibleForShares) {
                    // PopupView for Shares
                    PopupView(shareValues: $shareValues, selectedParticipants: $selectedParticipants) {
                        
                        var totalShares = shareValues.reduce(0, +)
                        for idx in 0..<selectedParticipants.count {
                            participants[idx].share = shareValues[idx]
                            participants[idx].amountToPay = (totalAmount / totalShares) * participants[idx].share
                        }
                        
                        isPopupVisibleForShares = false
                        
                    }
                }
                
                Button(action: {
                    isPopupVisibleForAmounts = true
                }) {
                    Text("Amounts")
                        .padding()
                        .foregroundColor(.white)
                }
                .background(Color.blue)
                .cornerRadius(8)
                .sheet(isPresented: $isPopupVisibleForAmounts) {
                    // PopupView for Shares
                    PopupView(shareValues: $shareValues, selectedParticipants: $selectedParticipants) {
                        isPopupVisibleForAmounts = false
                        // Action logic when "Done" is tapped
                    }
                }

                Button(action: {
                    isPopupVisibleForPercentages = true
                }) {
                    Text("%")
                        .padding()
                        .foregroundColor(.white)
                }
                .background(Color.blue)
                .cornerRadius(8)
                .sheet(isPresented: $isPopupVisibleForPercentages) {
                    // PopupView for Percentages
                    PopupView(shareValues: $shareValues, selectedParticipants: $selectedParticipants) {
                        isPopupVisibleForPercentages = false
                        // Action logic when "Done" is tapped
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
        } else {
            selectedParticipants.append(participant)
            shareValues.append(1)
        }
    }
}
