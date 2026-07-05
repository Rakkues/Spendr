//
//  StatisticsView.swift
//  Spendr
//
//  Created by Anas Azman on 15/04/2026.
//

import Charts
import SwiftUI

struct StatisticsView: View {
    @StateObject private var viewModel = StatisticsViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Top: Monthly net chart
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Monthly Net (\(viewModel.selectedYear, format: .number.grouping(.never)))")
                            .font(.headline)
                        Spacer()
                        Picker("Year", selection: $viewModel.selectedYear) {
                            let current = Calendar.current.component(.year, from: Date())
                            // Wrap the range in Array() so the compiler knows exactly how to iterate it
                            ForEach(Array((current - 1)...(current + 1)), id: \.self) { year in
                                Text(String(year)).tag(year)
                            }
                        }
                        .pickerStyle(.segmented)
                        .onChange(of: viewModel.selectedYear) { oldValue, newValue in
                            print("Picker changed from \(oldValue) to \(newValue)")
                            Task { await viewModel.loadMonthlyNet() }
                        }
                    }

                    if viewModel.hasMonthlyNetData {
                        Chart(viewModel.monthlyNet) { point in
                            // Transform integer month (1-12) into a localized string ("Jan", "Feb", etc.)
                            let monthName = DateFormatter().shortMonthSymbols[point.month - 1]
                            let markColor: Color = point.value >= 0 ? .green : .red

                            LineMark(
                                x: .value("Month", monthName), // Use the string name here so it charts categorically
                                y: .value("Net", point.value)
                            )
                            .foregroundStyle(markColor)

                            BarMark(
                                x: .value("Month", monthName),
                                y: .value("Net", point.value)
                            )
                            .opacity(0.25)
                            .foregroundStyle(markColor)
                        }
                        .frame(height: 220)
                    } else {
                        ContentUnavailableView(
                            "No entries yet",
                            systemImage: "chart.xyaxis.line",
                            description: Text("Add income and expenses to see your monthly net.")
                        )
                        .frame(height: 220)
                    }
                }

                Divider()

                // Bottom: Budgets progress
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Budgets (\(monthName(viewModel.selectedMonth)) \(viewModel.selectedYear, format: .number.grouping(.never)))")
                            .font(.headline)
                        Spacer()
                        Picker("Month", selection: $viewModel.selectedMonth) {
                            ForEach(1...12, id: \.self) { m in
                                Text(monthName(m)).tag(m)
                            }
                        }
                        .pickerStyle(.menu)
                    }

                    if !viewModel.budgets.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(viewModel.budgets) { budget in
                                let categoryId = budget.categoryId

                                // 2. Use that clean non-optional ID to check the dictionary
                                let spent = viewModel.monthlyExpensesByBudget[categoryId] ?? 0
                                let progress = max(0, min(1, budget.amount == 0 ? 0 : spent / budget.amount))
                                let categoryName = viewModel.categories.first(where: { $0.id == categoryId })?.name ?? "Budget"
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack {
                                        Text(categoryName)
                                            .font(.subheadline)
                                            .bold()
                                        Spacer()
                                        Text("RM\(spent, specifier: "%.2f") / RM\(budget.amount, specifier: "%.2f")")
                                            .font(.caption)
                                    }
                                    ProgressView(value: progress)
                                        .tint(progress < 1 ? .accentColor : .red)
                                }
                                .padding(12)
                                .background(Color.base, in: RoundedRectangle(cornerRadius: 12))
                            }
                        }
                    } else {
                        ContentUnavailableView(
                            "No budgets yet",
                            systemImage: "banknote",
                            description: Text("Create a budget to track your spending against your goals.")
                        )
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .padding()
        }
        .background(Color.crust)
        .navigationTitle("Statistics")
        .task { await viewModel.refresh() }
        .onChange(of: viewModel.selectedYear) {
            Task { await viewModel.loadMonthlyNet() }
        }
        .onChange(of: viewModel.selectedMonth) {
            Task { await viewModel.loadBudgetsProgress() }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("NewEntrySaved"))) { _ in
            Task {
                await viewModel.refresh()
            }
        }
    }

    private func monthName(_ month: Int) -> String {
        let df = DateFormatter()
        df.locale = .current
        return df.monthSymbols[max(0, min(11, month - 1))]
    }
}

#Preview {
    NavigationStack { StatisticsView() }
}
