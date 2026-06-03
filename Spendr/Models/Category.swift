//
//  Category.swift
//  Spendr
//
//  Created by Anas Azman on 03/05/2026.
//

import Foundation

struct Category: Identifiable, Decodable, Hashable {
    let id:  UUID
    let name: String
    let userId: UUID
    let iconName: String
    let colorHex: String
}
