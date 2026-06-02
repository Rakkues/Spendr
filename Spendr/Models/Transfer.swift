//
//  Transfer.swift
//  Spendr
//
//  Created by Anas Azman on 03/05/2026.
//

import Foundation

struct Transfer : Identifiable, Decodable {
    let id: UUID
    let date: Date
    let fromEntry: Entry
    let toEntry: Entry
}
