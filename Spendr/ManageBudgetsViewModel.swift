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
    
    func setBudget() async {}
}

struct CategoryBudgetRow: Decodable, Identifiable {
    let category: Category
    let budget: Budget?

    var id: UUID { category.id }

    enum CodingKeys: String, CodingKey {
        case budgets
    }

    init(from decoder: Decoder) throws {
        self.category = try Category(from: decoder)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let budgetsArray = try container.decodeIfPresent([Budget].self, forKey: .budgets)
        self.budget = budgetsArray?.first
    }
}
