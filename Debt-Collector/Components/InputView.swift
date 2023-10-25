//
//  InputView.swift
//  Debt-Collector
//
//  Created by Martin Sir on 10/17/23.
//

import SwiftUI

struct InputView: View {
    @Binding var text: String
    @FocusState var isFocused: Bool
    @EnvironmentObject var swiftUIShared: SwiftUIShared
    let placeholder: String
    var isSecuredField = false
    var invalidField = false
    
    var body: some View {
        VStack {
            VStack {
                if isSecuredField {
                    SecureInputView(placeholder, text: $text)
                        .font(.system(size: 16))
                        .focused($isFocused)
                        .frame(height: 18)
                        .simultaneousGesture(
                            TapGesture()
                                .onEnded { _ in
                                    // prevent hiding keyboard
                                }
                        )
                } else {
                    TextField(placeholder, text: $text)
                        .font(.system(size: 16))
                        .focused($isFocused)
                        .simultaneousGesture(
                            TapGesture()
                                .onEnded { _ in
                                    // prevent hiding keyboard
                                }
                        )
                        .frame(height: 18)
                }
                
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(invalidField ? Color.red : isFocused ? Color.blue : Color.gray)
            }
        }
    }
}

struct InputView_Preview: PreviewProvider {
    static var previews: some View {
        InputView(text: .constant(""), placeholder: "")
    }
}
