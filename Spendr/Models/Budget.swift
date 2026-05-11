//
//  Budget.swift
//  Spendr
//
//  Created by Anas Azman on 03/05/2026.
//

import Foundation

struct Budget: Identifiable {
    let id = UUID()
    var amount: Double
    var category: Category
    var month: Int
    var year: Int
}
