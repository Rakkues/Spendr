//
//  Account.swift
//  Spendr
//
//  Created by Anas Azman on 03/05/2026.
//

import Foundation

struct Account: Identifiable, Decodable, Hashable {
    let id: UUID
    let name: String
    let currencyCode: String
}
