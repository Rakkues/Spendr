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
    
    private let databaseService = SupabaseDatabaseService()

    func fetchCategoriesAndBudgets() async {
        do {
            // Extract and decode the underlying value payload directly
            let records = try await databaseService.fetchCategoryBudget()
            
            self.budgetRows = records
            self.errorMessage = nil
        } catch {
            print("❌ Fetch failed: \(error)")
            self.errorMessage = error.localizedDescription
        }
    }
    
    func saveBudget(amount: Double, for category: Category, currentBudget: Budget?) async {
        do {
            if let budget = currentBudget {
                // Update existing budget
                try await databaseService.updateBudget(budget, amount: amount)
            } else {
                // Insert new budget
                let newBudget = Budget(
                    id: UUID(),
                    amount: amount,
                    categoryId: category.id
                )
                
                try await databaseService.addBudget(newBudget)
            }
            // Reload list
            await fetchCategoriesAndBudgets()
        } catch {
            self.errorMessage = error.localizedDescription
            print("❌ Save budget failed: \(error)")
        }
    }
    
    func deleteBudget(_ budget: Budget) async {
        do {
            try await databaseService.deleteBudget(budget)
            
            // Reload list
            await fetchCategoriesAndBudgets()
        } catch {
            self.errorMessage = error.localizedDescription
            print("❌ Delete budget failed: \(error)")
        }
    }
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
