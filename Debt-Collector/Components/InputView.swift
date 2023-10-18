//
//  InputView.swift
//  Debt-Collector
//
//  Created by Martin Sir on 10/17/23.
//

import SwiftUI

struct InputView: View {
    @Binding var text: String
    let title: String
    let placeholder: String
    var isSecuredField = false
    
    
    var body: some View {
        VStack {
            if title != "" {
                Text(title)
                    .foregroundColor(Color(.darkGray))
                    .fontWeight(.semibold)
                    .font(.footnote)
            }
            
            if isSecuredField {
                SecureField(placeholder, text: $text)
                    .font(.system(size: 14))
            } else {
                TextField(placeholder, text: $text)
                    .font(.system(size: 14))
            }
                    
        }
    }
}

struct InputView_Preview: PreviewProvider {
    static var previews: some View {
        InputView(text: .constant(""), title: "", placeholder: "")
    }
}
