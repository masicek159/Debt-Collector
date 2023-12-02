//
//  FriendsSectionHeaderView.swift
//  Debt-Collector
//
//  Created by Martin Sir on 28.11.2023.
//

import SwiftUI

struct FriendsSectionHeaderView: View {
    @Binding var showPopup: Bool
    @Binding var isFriendListExpanded: Bool
    
    var body: some View {
        HStack {
            Text("Friends")
            
            Button(action: {
                isFriendListExpanded.toggle()
            }) {
                Image(systemName: isFriendListExpanded ? "chevron.down" : "chevron.up")
            }
            
            Spacer()
            
            Button(action: {
                showPopup = true
            }) {
                Image(systemName: "plus")
            }
        }
    }
}

struct FriendsSectionHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        FriendsSectionHeaderView(showPopup: .constant(false), isFriendListExpanded: .constant(false))
    }
}
