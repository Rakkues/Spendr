import Combine
import Foundation
import Supabase
import SwiftUI

struct MonthlyNetPoint: Identifiable {
    let id = UUID()
    let month: Int // 1...12
    let value: Double
}

@MainActor
final class StatisticsViewModel: ObservableObject {
    @Published var monthlyNet: [MonthlyNetPoint] = []
    @Published var budgets: [Budget] = []
    @Published var monthlyExpensesByBudget: [UUID: Double] = [:]
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    @Published var selectedYear: Int = Calendar.current.component(.year, from: Date())
    @Published var selectedMonth: Int = Calendar.current.component(.month, from: Date())
    
    private let databaseService = SupabaseDatabaseService()
    
    var hasMonthlyNetData: Bool {
        self.monthlyNet.contains { $0.value != 0 }
    }
    
    var hasBudgets: Bool {
        !self.budgets.isEmpty
    }
    
    init() {}
    
    func refresh() async {
        self.isLoading = true
        self.errorMessage = nil
        do {
            try await withThrowingTaskGroup(of: Void.self) { group in
                group.addTask { [weak self] in
                    await self?.loadMonthlyNet()
                }
                group.addTask { [weak self] in
                    await self?.loadBudgetsProgress()
                }
                try await group.waitForAll()
            }
        } catch {
            self.errorMessage = error.localizedDescription
        }
        self.isLoading = false
    }
    
    func loadMonthlyNet() async {
        do {
            // Fetch all entries, then filter locally by year. Adjust if your service supports server-side filters.
            let entries = try await databaseService.fetchEntries()
            let cal = Calendar.current
            let year = self.selectedYear
            var totals = Array(repeating: 0.0, count: 12)
            for e in entries {
                let comps = cal.dateComponents([.year, .month], from: e.date)
                guard comps.year == year, let m = comps.month else { continue }
                switch e.type {
                case .income:
                    totals[m-1] += e.amount
                case .expense:
                    totals[m-1] -= e.amount
                case .transfer:
                    break
                }
            }
            self.monthlyNet = (1 ... 12).map { m in MonthlyNetPoint(month: m, value: totals[m-1]) }
        } catch {
            self.errorMessage = error.localizedDescription
            self.monthlyNet = []
        }
    }
        
    func loadBudgetsProgress() async {
        do {
            let budgets = try await databaseService.fetchBudgets()
            self.budgets = budgets
            guard !budgets.isEmpty else {
                self.monthlyExpensesByBudget = [:]
                return
            }
            let entries = try await databaseService.fetchEntries()
            let (start, end) = self.monthDateRange(year: self.selectedYear, month: self.selectedMonth)
            let monthEntries = entries.filter { $0.date >= start && $0.date < end }
            var spent: [UUID: Double] = [:]
            for e in monthEntries where e.type == .expense {
                let categoryId = e.categoryId
                spent[categoryId, default: 0] += e.amount
            }
            self.monthlyExpensesByBudget = spent
        } catch {
            self.errorMessage = error.localizedDescription
            self.budgets = []
            self.monthlyExpensesByBudget = [:]
        }
    }
        
    private func monthDateRange(year: Int, month: Int) -> (Date, Date) {
        var comps = DateComponents()
        comps.year = year
        comps.month = month
        comps.day = 1
        let cal = Calendar.current
        let start = cal.date(from: comps) ?? Date()
        var add = DateComponents()
        add.month = 1
        let end = cal.date(byAdding: add, to: start) ?? start
        return (start, end)
    }
}
