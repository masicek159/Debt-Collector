//
//  GroupDetail.swift
//  Debt-Collector
//
//  Created by Martin Sir on 09.11.2023.
//

import SwiftUI

struct GroupDetail: View {
    var group: GroupModel
    
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
                
            }
        }
    }
}

struct GroupDetail_Previews: PreviewProvider {
    static var previews: some View {
        GroupDetail(group: GroupModel(id: "1", name: "Group name", currency: "USD", image: nil))
    }
}

