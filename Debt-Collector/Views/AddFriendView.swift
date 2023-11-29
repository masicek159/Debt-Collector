//
//  AddFriendView.swift
//  Debt-Collector
//
//  Created by Martin Sir on 27.11.2023.
//

import SwiftUI

protocol AddFriendFormProtocol {
    var isFormValid: Bool { get }
}

extension AddFriendView: AddFriendFormProtocol {
    var isFormValid: Bool {
        return !email.isEmpty
        && email.contains("@")
    }
}

struct AddFriendView: View {
    @State var email: String = ""
    @StateObject var viewModel: UserViewModel = UserViewModel()
    @State private var addFailed: Bool = false
    @State private var showAlert: Bool = false
    @Binding var showPopup: Bool
    
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                
                Button(action: {
                    showPopup = false
                }) {
                    Text("Cancel")
                        .padding()
                }
            }
            
            Form {
                VStack {
                    TextField("Email", text: $email)
                        .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
                    
                    Button(action: {
                        // add friend
                        Task {
                            addFailed = await !viewModel.addFriend(email: email)
                            showAlert = true
                        }
                    }) {
                        Text("Send a request")
                    }
                    .disabled(!isFormValid)
                    .opacity(isFormValid ? 1.0 : 0.5)
                }
            }
            .alert(isPresented: $showAlert) {
                if addFailed {
                    return Alert(
                        title: Text("Warning"),
                        message: Text("Failed to add friend!"),
                        dismissButton: .default(Text("OK"), action: {
                            showAlert = false
                        })
                    )
                } else {
                    return Alert(
                        title: Text("Success"),
                        message: Text("Friend added successfully!"),
                        primaryButton: .default(Text("Add another friend"), action: {
                            // Call your function here
                            email = ""
                            showAlert = false
                        }),
                        secondaryButton: .cancel(Text("Cancel"), action: {
                            showAlert = false
                            showPopup = false
                        })
                    )
                }
            }
            
        }
    }
}

#Preview {
    AddFriendView(showPopup: .constant(true))
}
