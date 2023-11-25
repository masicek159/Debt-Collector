//
//  CurrenciesHelper.swift
//  Debt-Collector
//
//  Created by Martin Sir on 06.11.2023.
//

import Foundation
import SwiftUI

class CurrenciesHelper: ObservableObject {
    static let shared = CurrenciesHelper()
    private init () {}
    @Published var currencies = ["USD", "EUR", "GBP", "JPY", "CAD", "CZK"]
}
