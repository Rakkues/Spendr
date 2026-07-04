//
//  ManageBudgetsViewModel.swift
//  Spendr
//
//  Created by Anas Azman on 04/07/2026.
//

import Combine
import Foundation
import Supabase

@MainActor
class ManageBudgetsViewModel: ObservableObject {
    @Published var budgetRows: [CategoryBudgetRow] = []
    @Published var errorMessage: String? = nil

    func fetchCategoriesAndBudgets() async {
        do {
            // Extract and decode the underlying value payload directly
            let records: [CategoryBudgetRow] = try await supabase
                .from("categories")
                .select("""
                    *,
                    budgets (
                        id,
                        amount
                    )
                """)
                .execute()
                .value
            
            self.budgetRows = records
            self.errorMessage = nil
        } catch {
            print("❌ Fetch failed: \(error)")
            self.errorMessage = error.localizedDescription
        }
    }
}

// This wrapper exists ONLY for your ManageBudgets screen
struct CategoryBudgetRow: Decodable, Identifiable {
    let category: Category // Your original, unmodified model
    let budget: Budget?    // Your original, unmodified model (Optional)

    var id: UUID { category.id } // Satisfies Identifiable for SwiftUI Lists

    enum CodingKeys: String, CodingKey {
        case budgets
    }

    init(from decoder: Decoder) throws {
        // 1. Decode the core Category object fields directly out of the root JSON container
        self.category = try Category(from: decoder)
        
        // 2. Safely unpack the PostgREST array relation into a single singular property
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let budgetsArray = try container.decodeIfPresent([Budget].self, forKey: .budgets)
        self.budget = budgetsArray?.first
    }
}
