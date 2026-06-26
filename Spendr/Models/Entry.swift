//
//  Entry.swift
//  Spendr
//
//  Created by Anas Azman on 03/05/2026.
//

import Foundation

enum EntryType: String, CaseIterable, Codable {
    case expense = "expense"
    case income = "income"
    case transfer = "transfer"
    
    var displayName: String {
        rawValue.capitalized
    }
}

struct Entry: Identifiable, Codable {
    let id: UUID
    let type: EntryType
    let date: Date
    let amount: Double
    let categoryId: UUID
    let name: String
    let accountId: UUID

    enum CodingKeys: String, CodingKey {
        case id
        case type
        case date
        case amount
        case categoryId = "category_id"
        case name
        case accountId = "account_id"
    }
}
