//
//  AddEntryViewModel.swift
//  Spendr
//
//  Created by Anas Azman on 02/06/2026.
//

import Combine
import Foundation
import Supabase

@MainActor
class AddEntryViewModel: ObservableObject {
    @Published var date = Date()
    @Published var name = ""
    @Published var type: EntryType = .expense
    @Published var entryName = ""
    @Published var account = ""
    @Published var amount = 0.0
    
    @Published var categories: [Category] = []
    @Published var selectedCategory: Category?
    
    @Published var accounts: [Account] = []
    @Published var selectedAccount: Account?
    
    @Published var errorMessage: String?
    
    func fetchCategories() async {
        guard let user = supabase.auth.currentUser else {
            self.errorMessage = "No user logged in"
            return
        }
        
        let userId = user.id.uuidString.lowercased()
        
        do {
            // 1. Fetch the raw response data
            let response = try await supabase
                .from("categories")
                .select("*")
                .eq("user_id", value: userId)
                .eq("entry_type", value: type.rawValue)
                .execute()
                        
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
                        
            let fetchedCategories = try decoder.decode([Category].self, from: response.data)
                        
            self.categories = fetchedCategories
        } catch {
            self.errorMessage = error.localizedDescription
            print("Error fetching categories: \(error)")
        }
    }
    
    func fetchAccounts() async {
        guard let user = supabase.auth.currentUser else {
            self.errorMessage = "No user logged in"
            return
        }
        
        let userId = user.id.uuidString.lowercased()
        
        do {
            // 1. Fetch the raw response data
            let response = try await supabase
                .from("accounts")
                .select("*")
                .eq("user_id", value: userId)
                .execute()
                        
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
                        
            let fetchedAccounts = try decoder.decode([Account].self, from: response.data)
                        
            self.accounts = fetchedAccounts
        } catch {
            self.errorMessage = error.localizedDescription
            print("Error fetching categories: \(error)")
        }
    }
    
    func addEntry() async {
        // Validate inputs
        guard let account = selectedAccount else {
            self.errorMessage = "Please select an account."
            return
        }
        guard let category = selectedCategory else {
            self.errorMessage = "Please select a category."
            return
        }
        guard amount > 0 else {
            self.errorMessage = "Amount must be greater than zero."
            return
        }
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            self.errorMessage = "Please enter a name."
            return
        }

        if (type != .transfer) {
            let entry = Entry(
                id: UUID(),
                type: type,
                date: date,
                amount: amount,
                categoryId: category.id,
                name: trimmedName,
                accountId: account.id
            )

            // Persist to Supabase
            do {
                try await supabase
                    .from("entries")
                    .insert(entry)
                    .execute()
                self.errorMessage = nil
            } catch {
                self.errorMessage = "Failed to save entry: \(error.localizedDescription)"
                print("Error pushing into database: \(error)")
            }
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

