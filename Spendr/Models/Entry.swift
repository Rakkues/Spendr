//
//  Entry.swift
//  Spendr
//
//  Created by Anas Azman on 03/05/2026.
//

import Foundation

enum EntryType {
    case expense
    case income
    case transfer
}

struct Entry: Identifiable {
    let id = UUID()
    var type: EntryType
    var date: Date
    var amount: Double
    var category: Category
    var name: String
    var account: String
}
