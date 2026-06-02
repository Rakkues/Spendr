//
//  Account.swift
//  Spendr
//
//  Created by Anas Azman on 03/05/2026.
//

import Foundation

struct Account: Identifiable, Decodable {
    let id: UUID
    let name: String
    let currencyCode: String
    let entries: [Entry]
}
