//
//  SwiftUIShared.swift
//  Debt-Collector
//
//  Created by Martin Sir on 22.10.2023.
//

import Foundation
import SwiftUI

class SwiftUIShared: ObservableObject {
    func hideKeyboard() {
        // Resign the first responder status (dismiss the keyboard)
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
