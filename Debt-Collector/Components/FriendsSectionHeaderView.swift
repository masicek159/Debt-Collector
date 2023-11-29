//
//  FriendsSectionHeaderView.swift
//  Debt-Collector
//
//  Created by Martin Sir on 28.11.2023.
//

import SwiftUI

struct FriendsSectionHeaderView: View {
    @Binding var showPopup: Bool
    
    var body: some View {
        HStack {
            Text("Friends")
            
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
        FriendsSectionHeaderView(showPopup: .constant(false))
    }
}
