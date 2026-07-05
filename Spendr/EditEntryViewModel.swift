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
    private let entry: Entry
    @Published var type: EntryType = .expense
    @Published var date: Date
    @Published var amount = 0.0
    @Published var name = ""

    @Published var categories: [Category] = []
    @Published var selectedCategory: Category?
    
    @Published var accounts: [Account] = []
    @Published var selectedAccount: Account?
    
    @Published var errorMessage: String?
    
    private let databaseService = SupabaseDatabaseService()
    
    init(entry: Entry) {
        self.entry = entry
        self.type = entry.type
        self.amount = entry.amount
        self.name = entry.name
        
        let secondsOffset = TimeInterval(TimeZone.current.secondsFromGMT(for: entry.date))
        self.date = entry.date.addingTimeInterval(secondsOffset)
    }
    
    func loadFormData() async {
        do {
            async let fetchedCategories = self.databaseService.fetchCategories(for: self.type.rawValue)
            async let fetchedAccounts = self.databaseService.fetchAccounts()
                
            self.categories = try await fetchedCategories
            self.accounts = try await fetchedAccounts
            
            // Preselect based on the entry's existing relationships
            self.selectedCategory = self.categories.first { $0.id == self.entry.categoryId }
            self.selectedAccount = self.accounts.first { $0.id == self.entry.accountId }
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    func updateEntry() async {
        guard let account = selectedAccount
        else {
            self.errorMessage = "Please select an account."
            return
        }
        guard let category = selectedCategory else {
            self.errorMessage = "Please select a category."
            return
        }
        guard self.amount > 0 else {
            self.errorMessage = "Amount must be greater than zero."
            return
        }
        let trimmedName = self.name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            self.errorMessage = "Please enter a name."
            return
        }
        
        do {
            let updatedEntry = Entry(
                id: self.entry.id,
                type: self.type,
                date: self.date,
                amount: self.amount,
                categoryId: category.id,
                name: trimmedName,
                accountId: account.id
            )

            try await databaseService.updateEntry(updatedEntry)
        } catch {
            print("Supabase Update Failed with Error: \(error)")
            print("Detailed Description: \(error.localizedDescription)")
            self.errorMessage = error.localizedDescription
        }
    }
    
    func deleteEntry() async {
        do {
            try await databaseService.deleteEntry(self.entry)
        } catch {
            print("❌ Supabase Update Failed with Error: \(error)")
            print("Detailed Description: \(error.localizedDescription)")
            self.errorMessage = error.localizedDescription
        }
    }
    
    var doubleFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.usesGroupingSeparator = true
        return formatter
    }
}
