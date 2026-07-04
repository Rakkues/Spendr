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
        let decoder = JSONDecoder()
        return decoder
    }

    func fetchCategories(for entryType: String) async throws -> [Category] {
        let userId = try currentUserId
        
        let response = try await supabase
            .from("categories")
            .select("*")
            .eq("user_id", value: userId)
            .eq("entry_type", value: entryType)
            .execute()
        
        return try decoder.decode([Category].self, from: response.data)
    }

    func fetchAccounts() async throws -> [Account] {
        let userId = try currentUserId
        
        let response = try await supabase
            .from("accounts")
            .select("*")
            .eq("user_id", value: userId)
            .execute()
        
        return try decoder.decode([Account].self, from: response.data)
    }

    func fetchEntries() async throws -> [Entry] {
        let userId = try currentUserId
        
        let response = try await supabase
            .from("entries")
            .select("*, accounts!inner(id, user_id)")
            .eq("accounts.user_id", value: userId)
            .in("type", values: ["expense", "income"])
            .execute()
        
        return try decoder.decode([Entry].self, from: response.data)
    }
    
    func fetchBudgets() async throws -> [Budget] {
        let userId = try currentUserId
        
        let response = try await supabase
            .from("accounts")
            .select("*")
            .eq("user_id", value: userId)
            .execute()
        
        return try decoder.decode([Budget].self, from: response.data)
    }
}
