//
//  ManageAccountsViewModel.swift
//  Spendr
//
//  Created by Anas Azman on 05/07/2026.
//

import Combine
import Foundation
import Supabase
import SwiftUI

@MainActor
class ManageAccountsViewModel: ObservableObject {
    @Published var accounts: [Account] = []
    @Published var errorMessage: String? = nil
    @Published var isLoading = false
    
    private let databaseService = SupabaseDatabaseService()
    
    // Type-safe model representing a new account structure to insert into database
    private struct InsertAccount: Codable {
        let id: UUID
        let name: String
        let currency_code: String
        let user_id: UUID
    }
    
    func fetchAccounts() async {
        self.isLoading = true
        defer { self.isLoading = false }
        
        do {
            self.accounts = try await databaseService.fetchAccounts()
            self.errorMessage = nil
        } catch {
            self.errorMessage = error.localizedDescription
            print("❌ Fetch accounts failed: \(error)")
        }
    }
    
    func saveAccount(name: String, currentAccount: Account?) async {
        guard let user = supabase.auth.currentUser else {
            self.errorMessage = "No user logged in"
            return
        }
        let userId = user.id
        
        self.isLoading = true
        defer { self.isLoading = false }
        
        do {
            if let account = currentAccount {
                // Update existing account
                try await supabase
                    .from("accounts")
                    .update(["name": name])
                    .eq("id", value: account.id)
                    .execute()
            } else {
                // Create and insert new account (hardcoded currency_code: "MYR")
                let newAccount = InsertAccount(
                    id: UUID(),
                    name: name,
                    currency_code: "MYR",
                    user_id: userId
                )
                
                try await supabase
                    .from("accounts")
                    .insert(newAccount)
                    .execute()
            }
            
            // Reload accounts list
            await fetchAccounts()
        } catch {
            self.errorMessage = error.localizedDescription
            print("❌ Save account failed: \(error)")
        }
    }
    
    func deleteAccount(_ account: Account) async {
        self.isLoading = true
        defer { self.isLoading = false }
        
        do {
            try await supabase
                .from("accounts")
                .delete()
                .eq("id", value: account.id)
                .execute()
            
            // Reload accounts list
            await fetchAccounts()
        } catch {
            self.errorMessage = error.localizedDescription
            print("❌ Delete account failed: \(error)")
        }
    }
}
