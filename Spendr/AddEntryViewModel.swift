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
    @Published var accounts: [Account] = []
    
    @Published var errorMessage: String?
    
    func fetchCategories() async {
        guard let user = supabase.auth.currentUser else {
            self.errorMessage = "No user logged in"
            return
        }
        
        let userId = user.id.uuidString.lowercased()
        print(userId)
        
        do {
            // 1. Fetch the raw response data
            let response = try await supabase
                .from("categories")
                .select("*")
                .eq("user_id", value: userId)
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
    
    func fetchAccounts() async {}

    var doubleFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter
    }
}
