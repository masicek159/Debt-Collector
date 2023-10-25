//
//  SecureInputView.swift
//  Debt-Collector
//
//  Created by Martin Sir on 24.10.2023.
//

import SwiftUI

struct SecureInputView: View {
    @Binding private var text: String
    @State private var isSecured: Bool = true
    @FocusState var isFocused: Bool
    private var placeholder: String
    
    init(_ placeholder: String, text: Binding<String>) {
        self.placeholder = placeholder
        self._text = text
    }
    
    var body: some View {
        ZStack(alignment: .trailing) {
            Group {
                if isSecured {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                }
            }

            Button(action: {
                isSecured.toggle()
            }) {
                Image(systemName: self.isSecured ? "eye.slash" : "eye")
                    .accentColor(.gray)
            }
        }
    }
}
