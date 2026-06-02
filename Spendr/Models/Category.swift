//
//  Category.swift
//  Spendr
//
//  Created by Anas Azman on 03/05/2026.
//

import Foundation

struct Category: Identifiable, Decodable {
    let id:  UUID
    let name: String
    let iconName: String
    let colorHex: String
}
