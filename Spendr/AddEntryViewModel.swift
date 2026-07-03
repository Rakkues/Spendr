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
    @Published var amount = 0.0
    
    @Published var categories: [Category] = []
    @Published var selectedCategory: Category?
    
    @Published var accounts: [Account] = []
    @Published var selectedAccount: Account?
    @Published var toAccount: Account?
    
    @Published var errorMessage: String?
    
    private let databaseService = SupabaseDatabaseService()
    
    func loadFormData() async {
        do {
            // Concurrent fetching makes this super fast!
            async let fetchedCategories = self.databaseService.fetchCategories(for: self.type.rawValue)
            async let fetchedAccounts = self.databaseService.fetchAccounts()
                
            self.categories = try await fetchedCategories
            self.accounts = try await fetchedAccounts
        } catch {
            self.errorMessage = error.localizedDescription
            print("Error loading form data: \(error)")
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
        guard self.amount > 0 else {
            self.errorMessage = "Amount must be greater than zero."
            return
        }
        let trimmedName = self.name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            self.errorMessage = "Please enter a name."
            return
        }

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
            NotificationCenter.default.post(name: NSNotification.Name("NewEntrySaved"), object: nil)
            self.errorMessage = nil
        } catch {
            self.errorMessage = "Failed to save entry: \(error.localizedDescription)"
            print("Error pushing into database: \(error)")
        }
    }
    
    func addTransfer() async {
        guard let user = supabase.auth.currentUser else {
            self.errorMessage = "No user logged in"
            return
        }
        guard let fromAccount = selectedAccount else {
            self.errorMessage = "Please select a source account."
            return
        }
        guard let toAccount = toAccount else {
            self.errorMessage = "Please select a destination account."
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
            
        let userId = user.id.uuidString.lowercased()
            
        do {
            let response = try await supabase
                .from("categories")
                .select("*")
                .eq("user_id", value: userId)
                .eq("entry_type", value: "transfer")
                .single()
                .execute()
                
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
                
            let transferCategory = try decoder.decode(Category.self, from: response.data)
                
            let fromEntry = Entry(
                id: UUID(),
                type: .transfer,
                date: date,
                amount: amount,
                categoryId: transferCategory.id,
                name: trimmedName,
                accountId: fromAccount.id
            )
                
            let toEntry = Entry(
                id: UUID(),
                type: .transfer,
                date: date,
                amount: amount,
                categoryId: transferCategory.id,
                name: trimmedName,
                accountId: toAccount.id
            )
                
            let transfer = Transfer(
                id: UUID(),
                date: date,
                amount: amount,
                name: trimmedName,
                fromAccountId: fromAccount.id,
                toAccountId: toAccount.id,
                fromEntryId: fromEntry.id,
                toEntryId: toEntry.id
            )
                
            // Insert entries into db
            try await supabase
                .from("entries")
                .insert([fromEntry, toEntry])
                .execute()
                
            // Insert transfer into db
            try await supabase
                .from("transfers")
                .insert(transfer)
                .execute()
                
            self.errorMessage = nil
                
        } catch {
            self.errorMessage = "Failed to save transfer: \(error.localizedDescription)"
            print("Error pushing transfer entries into database: \(error)")
        }
    }
    
    func reset() {
        self.date = Date()
        self.name = ""
        self.type = .expense
        self.amount = 0.0

        // Clear Picker selections to avoid invalid tags
        self.selectedCategory = nil
        self.selectedAccount = nil
        self.toAccount = nil
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
