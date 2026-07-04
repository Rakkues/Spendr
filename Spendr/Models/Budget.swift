//
//  Budget.swift
//  Spendr
//
//  Created by Anas Azman on 03/05/2026.
//

import Foundation

struct Budget: Identifiable, Codable, Hashable {
    let id: UUID
    let amount: Double
    let categoryId: UUID
    
    enum CodingKeys: String, CodingKey {
        case id
        case amount
        case categoryId = "category_id"
    }
}
