//
//  DatabaseServiceProtocol.swift
//  Spendr
//
//  Created by Anas Azman on 30/06/2026.
//

import Foundation
import Supabase

protocol DatabaseServiceProtocol {
    func fetchCategories(for entryType: String) async throws -> [Category]
    func fetchAccounts() async throws -> [Account]
}

final class SupabaseDatabaseService: DatabaseServiceProtocol {
    /// Helper to get current user ID safely
    private var currentUserId: String {
        get throws {
            guard let user = supabase.auth.currentUser else {
                throw NSError(domain: "AuthService", code: 401, userInfo: [NSLocalizedDescriptionKey: "No user logged in"])
            }
            return user.id.uuidString.lowercased()
        }
    }
    
    private var decoder: JSONDecoder {
        return JSONDecoder()
    }

    /// Fetch functions
    func fetchCategories(for entryType: String) async throws -> [Category] {
        let userId = try currentUserId
        
        let categories: [Category] = try await supabase
            .from("categories")
            .select("*")
            .eq("user_id", value: userId)
            .eq("entry_type", value: entryType)
            .execute()
            .value
        
        return categories
    }
    
    func fetchTransferCategory() async throws -> Category {
        let userId = try currentUserId
        
        let categories: [Category] = try await supabase
            .from("categories")
            .select("*")
            .eq("user_id", value: userId)
            .eq("entry_type", value: "transfer")
            .execute()
            .value
        
        guard let transferCategory = categories.first else {
            throw NSError(
                domain: "SupabaseDatabaseService",
                code: 404,
                userInfo: [NSLocalizedDescriptionKey: "Transfer category not found in the database. Please verify that your data is seeded."]
            )
        }
        
        return transferCategory
    }

    func fetchAccounts() async throws -> [Account] {
        let userId = try currentUserId
        
        let accounts: [Account] = try await supabase
            .from("accounts")
            .select("*")
            .eq("user_id", value: userId)
            .execute()
            .value
        
        return accounts
    }

    func fetchEntries() async throws -> [Entry] {
        let userId = try currentUserId
        
        let entries: [Entry] = try await supabase
            .from("entries")
            .select("*, accounts!inner(id, user_id)")
            .eq("accounts.user_id", value: userId)
            .in("type", values: ["expense", "income"])
            .execute()
            .value
        
        return entries
    }
    
    func fetchBudgets() async throws -> [Budget] {
        let userId = try currentUserId
        
        let budgets: [Budget] = try await supabase
            .from("accounts")
            .select("*")
            .eq("user_id", value: userId)
            .execute()
            .value
        
        return budgets
    }
    
    /// Insert functions
    func addEntry(_ entry: Entry) async throws {
        try await supabase
            .from("entries")
            .insert(entry)
            .execute()
     }
    
    func addTransfer(from fromEntry: Entry, to toEntry: Entry, transfer: Transfer) async throws {
        try await supabase
            .from("entries")
            .insert([fromEntry, toEntry])
            .execute()
            
        // Insert transfer into db
        try await supabase
            .from("transfers")
            .insert(transfer)
            .execute()
    }
    
    // Delete functions
    func deleteEntry(_ entry: Entry) async throws {
        try await supabase
            .from("entries")
            .delete()
            .eq("id", value: entry.id)
            .execute()
    }
    
    // Update functions
    func updateEntry(_ updatedEntry: Entry) async throws {
        let response = try await supabase
            .from("entries")
            .update(updatedEntry)
            .eq("id", value: updatedEntry.id)
            .execute()
    }
}
