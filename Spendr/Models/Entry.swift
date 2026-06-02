//
//  Entry.swift
//  Spendr
//
//  Created by Anas Azman on 03/05/2026.
//

import Foundation

enum EntryType: String, CaseIterable, Decodable  {
    case expense = "Expense"
    case income = "Income"
    case transfer = "Transfer"
}

struct Entry: Identifiable, Decodable {
    let id: UUID
    let type: EntryType
    let date: Date
    let amount: Double
    let category: Category
    let name: String
    let account: String
}
