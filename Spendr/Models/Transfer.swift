//
//  Transfer.swift
//  Spendr
//
//  Created by Anas Azman on 03/05/2026.
//

import Foundation

struct Transfer : Identifiable {
    let id = UUID()
    var date: Date
    var fromEntry: Entry
    var toEntry: Entry
}
