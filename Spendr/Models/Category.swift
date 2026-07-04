//
//  Category.swift
//  Spendr
//
//  Created by Anas Azman on 03/05/2026.
//

import Foundation

struct Category: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let userId: UUID
    let iconName: String
    let colorHex: String
    let entryType: EntryType
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case userId = "user_id"
        case iconName = "icon_name"
        case colorHex = "color_hex"
        case entryType = "entry_type"
    }
}
