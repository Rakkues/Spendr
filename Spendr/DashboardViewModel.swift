//
//  DashboardViewModel.swift
//  Spendr
//
//  Created by Anas Azman on 25/06/2026.
//

import Combine
import Foundation
import Supabase
import SwiftUI

@MainActor
class DashboardViewModel: ObservableObject {
    @Published var entries: [Entry] = []
    @Published var categories: [Category] = []
    @Published var accounts: [Account] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    private let databaseService = SupabaseDatabaseService()

    struct CategorySlice: Identifiable {
        let id = UUID()
        let name: String
        let amount: Double
        let color: Color
        let iconName: String
    }

    var categorySlices: [CategorySlice] {
        // 1. Filter out only expense entries
        let expenseEntries = self.entries.filter { $0.type == .expense }

        // 2. Group the expenses by their categoryId
        // Result: [UUID: [Entry]]
        let groupedExpenses = Dictionary(grouping: expenseEntries) { $0.categoryId }

        // 3. Map the groups into CategorySlice objects
        let slices = groupedExpenses.compactMap { categoryId, entriesForCategory -> CategorySlice? in
            // Find the actual Category details from your loaded categories array
            guard let matchingCategory = categories.first(where: { $0.id == categoryId }) else {
                return nil // Skip this slice if the category definition hasn't loaded yet
            }

            // Sum up the total amount for this specific category
            let totalAmount = entriesForCategory.reduce(0.0) { $0 + $1.amount }

            // Return the slice with the category's custom color mapping
            return CategorySlice(
                name: matchingCategory.name,
                amount: totalAmount,
                color: Color(hex: matchingCategory.colorHex),
                iconName: matchingCategory.iconName
            )
        }

        // 4. Sort from highest spending to lowest (makes charts look much cleaner)
        return slices.sorted { $0.amount > $1.amount }
    }

    /// Selected month anchor (defaults to the current month)
    /// Instead of = .init()
    @Published var selectedMonth: Date = {
        let cal = Calendar.current
        return cal.date(from: cal.dateComponents([.year, .month], from: Date())) ?? Date()
    }()

    private let calendar = Calendar.current

    var monthInterval: (start: Date, end: Date)? {
        // Start = beginning of selected month, End = beginning of next month
        guard let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedMonth)),
              let nextMonth = calendar.date(byAdding: DateComponents(month: 1), to: monthStart)
        else {
            return nil
        }
        return (start: monthStart, end: nextMonth)
    }

    /// Entries already filtered by month on fetch; expose a sorted view
    var filteredEntries: [Entry] {
        self.entries.sorted { $0.date > $1.date }
    }

    func setMonth(_ date: Date) async {
        self.selectedMonth = date
        await self.fetchEntriesForSelectedMonth()
    }
    
    func refreshDashboard() async {
        await self.fetchAccounts()
        await self.fetchCategories()
        await self.fetchEntriesForSelectedMonth()
    }

    func fetchEntriesForSelectedMonth() async {
        guard let interval = monthInterval else {
            self.errorMessage = "Invalid month interval"
            self.entries = []
            return
        }

        self.isLoading = true
        defer { isLoading = false }

        do {
            self.entries = try await databaseService.fetchMontlyEntries(interval)
            self.errorMessage = nil
        } catch {
            self.errorMessage = error.localizedDescription
            self.entries = []
            print("Error fetching dashboard entries: \(error)")
        }
    }
    
    func calculateEntries() -> Double {
        var netEntries = 0.0
        
        for entry in self.entries {
            if (entry.type == .expense) {
                netEntries -= entry.amount
            } else {
                netEntries += entry.amount
            }
        }
        
        return netEntries
    }

    func fetchCategories() async {
        do {
            self.categories = try await databaseService.fetchCategories()
        } catch {
            self.errorMessage = error.localizedDescription
            print("Error fetching categories: \(error)")
        }
    }

    func fetchAccounts() async {
        do {
            self.accounts = try await databaseService.fetchAccounts()
        } catch {
            self.errorMessage = error.localizedDescription
            print("Error fetching categories: \(error)")
        }
    }
}
