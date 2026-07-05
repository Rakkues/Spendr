//
//  DatabaseServiceProtocol.swift
//  Spendr
//
//  Created by Anas Azman on 30/06/2026.
//

import Foundation
import Supabase

protocol DatabaseServiceProtocol {
    func fetchCategories(for entryType: String?) async throws -> [Category]
    func fetchAccounts() async throws -> [Account]
}

extension DatabaseServiceProtocol {
    func fetchCategories(for entryType: String? = nil) async throws -> [Category] {
        try await fetchCategories(for: entryType)
    }
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
    func fetchCategories(for entryType: String?) async throws -> [Category] {
        let userId = try currentUserId
        
        var query = supabase
            .from("categories")
            .select("*")
            .eq("user_id", value: userId)
        
        if let entryType = entryType {
            query = query.eq("entry_type", value: entryType)
        }
        
        return try await query.execute().value
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
        
        return try await supabase
            .from("accounts")
            .select("*")
            .eq("user_id", value: userId)
            .execute()
            .value
    }

    func fetchEntries() async throws -> [Entry] {
        let userId = try currentUserId
        
        return try await supabase
            .from("entries")
            .select("*, accounts!inner(id, user_id)")
            .eq("accounts.user_id", value: userId)
            .in("type", values: ["expense", "income"])
            .execute()
            .value
    }
    
    func fetchMontlyEntries(_ interval: (start: Date, end: Date)) async throws -> [Entry] {
        let userId = try currentUserId
        
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withFullDate]
        let startISO = isoFormatter.string(from: interval.start)
        let endISO = isoFormatter.string(from: interval.end)
        
        return try await supabase
            .from("entries")
            // 1. Join the accounts table and select the fields you need
            .select("*, accounts!inner(id, user_id)")
            // 2. Filter using the syntax: tableName.columnName
            .eq("accounts.user_id", value: userId)
            .gt("date", value: startISO)
            .lte("date", value: endISO)
            .order("date", ascending: false)
            .execute()
            .value
    }
    
    func fetchBudgets() async throws -> [Budget] {
        let userId = try currentUserId

        return try await supabase
            .from("budgets")
            // 1. Join categories table to get user_id
            .select("*, categories!inner(id, user_id)")
            // 2. Filter by the category's owner ID
            .eq("categories.user_id", value: userId)
            .execute()
            .value
    }
    
    func fetchCategoryBudget() async throws -> [CategoryBudgetRow] {
        return try await supabase
            .from("categories")
            .select("""
                *,
                budgets (
                    id,
                    amount,
                    category_id
                )
            """)
            .execute()
            .value
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
    
    func addBudget(_ budget: Budget) async throws {
        try await supabase
            .from("budgets")
            .insert(budget)
            .execute()
    }
    
    /// Delete functions
    func deleteEntry(_ entry: Entry) async throws {
        try await supabase
            .from("entries")
            .delete()
            .eq("id", value: entry.id)
            .execute()
    }
    
    func deleteBudget(_ budget: Budget) async throws {
        try await supabase
            .from("budgets")
            .delete()
            .eq("id", value: budget.id)
            .execute()
    }
    
    /// Update functions
    func updateEntry(_ updatedEntry: Entry) async throws {
        try await supabase
            .from("entries")
            .update(updatedEntry)
            .eq("id", value: updatedEntry.id)
            .execute()
    }
    
    func updateBudget(_ updatedBudget: Budget, amount: Double) async throws {
        try await supabase
            .from("budgets")
            .update(["amount": amount])
            .eq("id", value: updatedBudget.id)
            .execute()
    }
}
