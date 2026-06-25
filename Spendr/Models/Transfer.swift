//
//  Transfer.swift
//  Spendr
//
//  Created by Anas Azman on 03/05/2026.
//

import Foundation

struct Transfer: Identifiable, Codable {
    let id: UUID
    let date: Date
    let amount: Double
    let name: String
    let fromAccountId: UUID
    let toAccountId: UUID
    let fromEntryId: UUID
    let toEntryId: UUID

    enum CodingKeys: String, CodingKey {
        case id
        case date
        case amount
        case name
        case fromAccountId = "from_account_id"
        case toAccountId = "to_account_id"
        case fromEntryId = "from_entry_id"
        case toEntryId = "to_entry_id"
    }
}
