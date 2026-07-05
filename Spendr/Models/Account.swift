//
//  Account.swift
//  Spendr
//
//  Created by Anas Azman on 03/05/2026.
//

import Foundation

struct Account: Identifiable, Codable, Hashable {
    let id: UUID
    let userId: UUID
    let name: String
    let currencyCode: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case name
        case currencyCode = "currency_code"
    }
}
