//
//  ManageBudgetsView.swift
//  Spendr
//
//  Created by Anas Azman on 04/07/2026.
//

import SwiftUI

struct ManageBudgetsView: View {
    @StateObject private var viewModel = ManageBudgetsViewModel()
    
    // 1. Change this to track the row wrapper instead
    @State private var selectedRow: CategoryBudgetRow? = nil
    
    var body: some View {
        ZStack {
            Color(.crust)
                .ignoresSafeArea()
            
            Group {
                // 2. Read from budgetRows array
                if viewModel.budgetRows.isEmpty {
                    ProgressView("Loading Categories...")
                        .tint(.primary)
                } else {
                    List {
                        Section(header: Text("Category Budgets")) {
                            ForEach(viewModel.budgetRows) { row in
                                Button {
                                    selectedRow = row // 3. Select the whole row metadata
                                } label: {
                                    HStack {
                                        // 4. Access individual values cleanly through row fields
                                        Label(row.category.name, systemImage: row.category.iconName ?? "questionmark")
                                            .foregroundColor(.primary)
                                        
                                        Spacer()
                                        
                                        if let budget = row.budget {
                                            Text("RM\(budget.amount, specifier: "%.2f")")
                                                .fontWeight(.semibold)
                                                .foregroundColor(.primary)
                                        } else {
                                            Text("Set Budget")
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                                .italic()
                                        }
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.footnote)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                        .listRowBackground(Color.base)
                    }
                    .scrollContentBackground(.hidden)
                }
            }
        }
        .navigationTitle("Manage Budgets")
        .task {
            await viewModel.fetchCategoriesAndBudgets()
        }
        .sheet(item: $selectedRow) { row in
            EditBudgetSheet(
                category: row.category,
                currentBudget: row.budget
            ) { amount in
                Task {
                    await viewModel.saveBudget(amount: amount, for: row.category, currentBudget: row.budget)
                    selectedRow = nil
                }
            } onDelete: {
                Task {
                    if let budget = row.budget {
                        await viewModel.deleteBudget(budget)
                    }
                    selectedRow = nil
                }
            }
        }
    }
}
