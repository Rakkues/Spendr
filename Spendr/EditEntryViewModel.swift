//
//  EditEntryViewModel.swift
//  Spendr
//
//  Created by Anas Azman on 29/06/2026.
//

import Combine
import Foundation
import Supabase

@MainActor
class EditEntryViewModel: ObservableObject {
    @Published var date = Date()
    @Published var name = ""
    @Published var type: EntryType = .expense
    @Published var entryName = ""
    @Published var amount = 0.0
    
    @Published var categories: [Category] = []
    @Published var selectedCategory: Category?
    
    @Published var accounts: [Account] = []
    @Published var selectedAccount: Account?
    @Published var toAccount: Account?
    
    @Published var errorMessage: String?
}
