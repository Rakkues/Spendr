//
//  Budget.swift
//  Spendr
//
//  Created by Anas Azman on 03/05/2026.
//

import Foundation

struct Budget: Identifiable, Decodable {
    let id: UUID
    let amount: Double
    let category: Category
    let month: Int
    let year: Int
}
