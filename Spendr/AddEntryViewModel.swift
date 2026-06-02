//
//  AddEntryViewModel.swift
//  Spendr
//
//  Created by Anas Azman on 02/06/2026.
//

import Foundation
import Combine

@MainActor
class AddEntryViewModel: ObservableObject {
    @Published var date = Date()
    @Published var name = ""
    @Published var type: EntryType = .expense
    @Published var entryName = ""
    @Published var account = ""
    @Published var amount = 0.0

    var doubleFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter
    }
}
