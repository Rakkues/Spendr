//
//  Category.swift
//  Spendr
//
//  Created by Anas Azman on 03/05/2026.
//

import Foundation

struct Category: Identifiable {
    var id = UUID()
    var name: String
    var iconName: String
    var colorHex: String
}
