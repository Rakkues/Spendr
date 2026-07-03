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

    func fetchEntriesForSelectedMonth() async {
        guard let user = supabase.auth.currentUser else {
            self.errorMessage = "No user logged in"
            self.entries = []
            return
        }
        guard let interval = monthInterval else {
            self.errorMessage = "Invalid month interval"
            self.entries = []
            return
        }

        self.isLoading = true
        defer { isLoading = false }

        let userId = user.id.uuidString.lowercased()

        // Format dates as ISO8601 (date-only or full). Assuming your `entries.date` is stored as timestamp/date in Supabase.
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withFullDate]
        let startISO = isoFormatter.string(from: interval.start)
        let endISO = isoFormatter.string(from: interval.end)

        do {
            // entry_type IN ('expense','income') and date >= start and date < end
            let response = try await supabase
                .from("entries")
                // 1. Join the accounts table and select the fields you need
                .select("*, accounts!inner(id, user_id)")
                // 2. Filter using the syntax: tableName.columnName
                .eq("accounts.user_id", value: userId)
                .in("type", values: ["expense", "income"])
                .gt("date", value: startISO)
                .lte("date", value: endISO)
                .order("date", ascending: false)
                .execute()

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .custom { decoder in
                let container = try decoder.singleValueContainer()
                let dateStr = try container.decode(String.self)
                
                let pureDateFormatter = DateFormatter()
                pureDateFormatter.dateFormat = "yyyy-MM-dd"
                if let date = pureDateFormatter.date(from: dateStr) { return date }
                
                let fractionalFormatter = ISO8601DateFormatter()
                fractionalFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                if let date = fractionalFormatter.date(from: dateStr) { return date }

                let standardFormatter = ISO8601DateFormatter()
                if let date = standardFormatter.date(from: dateStr) { return date }

                // If all fail, throw a clean error telling you exactly what string caused the crash
                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "Cannot decode date string: \(dateStr)"
                )
            }

            let fetched = try decoder.decode([Entry].self, from: response.data)
            self.entries = fetched

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
        guard let user = supabase.auth.currentUser else {
            self.errorMessage = "No user logged in"
            return
        }

        let userId = user.id.uuidString.lowercased()

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

    func fetchAccounts() async {
        guard let user = supabase.auth.currentUser else {
            self.errorMessage = "No user logged in"
            return
        }

        let userId = user.id.uuidString.lowercased()

        do {
            // 1. Fetch the raw response data
            let response = try await supabase
                .from("accounts")
                .select("*")
                .eq("user_id", value: userId)
                .execute()

            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase

            let fetchedAccounts = try decoder.decode([Account].self, from: response.data)

            self.accounts = fetchedAccounts
        } catch {
            self.errorMessage = error.localizedDescription
            print("Error fetching categories: \(error)")
        }
    }
}
