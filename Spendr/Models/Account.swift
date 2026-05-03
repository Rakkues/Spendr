//
//  Account.swift
//  Spendr
//
//  Created by Anas Azman on 03/05/2026.
//

import Foundation

struct Account: Identifiable {
    let id = UUID()
    var name: String
    var currencyCode: String
    var entries: [Entry]
}
