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
    @Published var type: EntryType = .expense
    @Published var date = Date()
    @Published var amount = 0.0
    @Published var name = ""

    @Published var categories: [Category] = []
    @Published var selectedCategory: Category?
    
    @Published var accounts: [Account] = []
    @Published var selectedAccount: Account?
    @Published var toAccount: Account?
    
    @Published var errorMessage: String?
    
    private let databaseService = SupabaseDatabaseService()
    
    init(entry: Entry) {
        self.type = entry.type
        self.date = entry.date
        self.amount = entry.amount
        self.name = entry.name
    }
    
    func loadFormData() async {
        do {
            async let fetchedCategories = self.databaseService.fetchCategories(for: self.type.rawValue)
            async let fetchedAccounts = self.databaseService.fetchAccounts()
                
            self.categories = try await fetchedCategories
            self.accounts = try await fetchedAccounts
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
}
