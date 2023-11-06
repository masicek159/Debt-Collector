//
//  CurrenciesHelper.swift
//  Debt-Collector
//
//  Created by Martin Sir on 06.11.2023.
//

import Foundation
import SwiftUI

class CurrenciesHelper: ObservableObject {
    @Published var currencies = ["USD", "EUR", "GBP", "JPY", "CAD", "CZK"]
}
