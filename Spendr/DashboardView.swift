//
//  DashboardView.swift
//  Spendr
//
//  Created by Anas Azman on 15/04/2026.
//

import Charts
import SwiftUI

extension Color {
    init(hex: String) {
        var hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct DayEntries {
    let entries: [Entry]
    let netExpense: Double
}

struct DashboardView: View {
    @State private var isExpanded = false
    @StateObject var viewModel = DashboardViewModel()

    private var monthOptions: [Date] {
        let calendar = Calendar.current
        // Force the baseline to be the clean start of the current month
        let startOfThisMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: Date()))!

        return (0 ..< 12).compactMap { offset in
            let rawMonth = calendar.date(byAdding: .month, value: -offset, to: startOfThisMonth)!
            // Ensure even the offset months are strictly stripped of random hours/minutes
            return calendar.date(from: calendar.dateComponents([.year, .month], from: rawMonth))
        }
    }

    private var monthFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateFormat = "MMMM yyyy"
        return df
    }

    private var groupedEntries: [DateComponents: DayEntries] {
        let grouped = Dictionary(grouping: viewModel.entries) { entry in
            Calendar.current.dateComponents([.day, .year, .month], from: entry.date)
        }
        return grouped.mapValues { entries in
            let net = entries.reduce(0.0) { sum, entry in
                switch entry.type {
                case .income:
                    return sum + Double(entry.amount)
                case .expense:
                    return sum - Double(entry.amount)
                case .transfer:
                    return sum
                }
            }
            return DayEntries(entries: entries, netExpense: net)
        }
    }

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                if !isExpanded {
                    // Donut chart
                    ZStack {
                        ConcentricRectangle(
                            topLeadingCorner: .concentric(minimum: 16),
                            topTrailingCorner: .concentric(minimum: 16)
                        )
                        .fill(Color.base)
                        .overlay(
                            VStack(spacing: 8) {
                                Text("Spending Distribution")
                                    .font(.headline)
                                Spacer()
                                if viewModel.categorySlices.isEmpty {
                                    Text("There is no data to be displayed for this month.")
                                } else {
                                    Chart(viewModel.categorySlices) { slice in
                                        SectorMark(
                                            angle: .value("Amount", slice.amount),
                                            innerRadius: .ratio(0.8),
                                            angularInset: 1.0
                                        )
                                        .foregroundStyle(by: .value("Category", slice.name))
                                        .cornerRadius(5.0)
                                    }
                                    .frame(height: 250)
                                    .chartForegroundStyleScale(
                                        domain: viewModel.categorySlices.map { $0.name },
                                        range: viewModel.categorySlices.map { $0.color }
                                    )
                                    .chartLegend(position: .bottom, alignment: .center, spacing: 20)
                                    .chartBackground { _ in
                                        NetSpending(netEntries: viewModel.calculateEntries())
                                    }
                                }
                                Spacer()
                            }
                            .padding()
                        )
                    }
                    .frame(height: geometry.size.height * 0.5)
                }

                // Expand list button
                Button(action: {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                        isExpanded.toggle()
                    }
                }) {
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.up")
                        .font(.headline)
                        .padding(8)
                        .frame(maxWidth: .infinity)
                        .background(Color.crust)
                        .accessibilityLabel(isExpanded ? "Collapse" : "Expand")
                }

                // Date entries
                if viewModel.entries.isEmpty && !viewModel.isLoading {
                    VStack {
                        Image("NoTransactions")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100, height: 100)
                        Text("No entry data available.")
                    }
                    .frame(height: isExpanded ? geometry.size.height : geometry.size.height * 0.5)
                    .frame(maxWidth: .infinity)
                    .background(Color.surface0)
                    .listRowInsets(EdgeInsets())
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(groupedEntries.sorted(by: { lhs, rhs in
                                let lhsDate = Calendar.current.date(from: lhs.key) ?? Date.distantPast
                                let rhsDate = Calendar.current.date(from: rhs.key) ?? Date.distantPast
                                return lhsDate > rhsDate
                            }), id: \.key) { dateComponents, dayEntries in
                                DateEntries(entry: (key: dateComponents, value: dayEntries.entries), netExpense: dayEntries.netExpense, viewModel: viewModel)
                            }
                            .listRowInsets(EdgeInsets())
                        }
                    }
                    .listStyle(.plain)
                    .frame(height: isExpanded ? geometry.size.height : geometry.size.height * 0.5)
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
                }
            }
            .animation(.spring(response: 0.35, dampingFraction: 0.85), value: isExpanded)
        }
        .ignoresSafeArea(edges: .bottom)
        .background(Color.crust)
        .foregroundColor(.text)
        .task {
            await viewModel.refreshDashboard()
        }
        .onChange(of: viewModel.selectedMonth) {
            Task { await viewModel.setMonth(viewModel.selectedMonth) }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("NewEntrySaved"))) { _ in
            Task {
                print("Observed new entry insertion! Refreshing chart dataset...")
                await viewModel.refreshDashboard()
            }
        }
        .onAppear {
            let cal = Calendar.current
            if let start = cal.date(from: cal.dateComponents([.year, .month], from: viewModel.selectedMonth)) {
                viewModel.selectedMonth = start
            }
        }
        .navigationDestination(for: Entry.self) { selectedEntry in
            EditEntryView(viewModel: EditEntryViewModel(entry: selectedEntry))
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Picker("Month", selection: $viewModel.selectedMonth) {
                    ForEach(monthOptions, id: \.self) { month in
                        Text(monthFormatter.string(from: month)).tag(month)
                    }
                }
                .pickerStyle(.menu)
                .padding(8)
                .tint(.primary)
                .glassEffect()
                .labelsHidden()
            }
            ToolbarItem(placement: .primaryAction) {
                NavigationLink {
                    AddEntryView(viewModel: AddEntryViewModel())
                } label: {
                    Image(systemName: "plus")
                        .font(.body.bold()) // Matches native navbar item sizes
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct NetSpending: View {
    let netEntries: Double

    private var textColor: Color {
        if netEntries < 0 {
            return .catRed
        } else if netEntries > 0 {
            return .catGreen
        } else {
            return .text
        }
    }

    var body: some View {
        VStack {
            Text("Net Spendings:")
                .font(.system(size: 12))
            if netEntries <= 0 {
                Text(netEntries, format: .currency(code: "MYR"))
                    .foregroundStyle(Color.catRed)
            } else if netEntries == 0 {
                Text(netEntries, format: .currency(code: "MYR"))
                    .foregroundStyle(Color.text)
            } else {
                Text(netEntries, format: .currency(code: "MYR"))
                    .foregroundStyle(Color.catGreen)
            }
        }
    }
}

struct DayHeader: View {
    let date: String
    let amount: Double

    var body: some View {
        HStack {
            Text(date)
            Spacer()
            Text(amount, format: .currency(code: "MYR"))
        }
        .padding()
        .background(Color.surface0)
    }
}

struct EntryRow: View {
    let description: String
    let account: String
    let amount: Double
    let type: EntryType
    let category: Category

    var body: some View {
        HStack {
            ZStack {
                Circle()
                    .scale(1)
                    .fill(Color(hex: category.colorHex))
                Image(systemName: category.iconName)
                    .foregroundStyle(Color.black)
            }
            .frame(maxWidth: 75)
            VStack(alignment: .leading) {
                Text(description)
                Text(account)
                    .font(.system(size: 11))
                    .foregroundStyle(Color.subtext1)
            }
            Spacer()

            switch type {
            case .income:
                Text(amount, format: .currency(code: "MYR"))
                    .padding()
                    .foregroundStyle(Color.catGreen)
            case .expense:
                Text(-amount, format: .currency(code: "MYR"))
                    .padding()
                    .foregroundStyle(Color.catRed)
            case .transfer:
                Text(amount, format: .currency(code: "MYR"))
                    .padding()
                    .foregroundStyle(Color.text)
            }
        }
        .padding(5)
        .background(Color.surface1)
    }
}

struct DateEntries: View {
    let entry: (key: DateComponents, value: [Entry])
    let netExpense: Double
    let viewModel: DashboardViewModel

    private func formattedDate(from components: DateComponents) -> String {
        guard let date = Calendar.current.date(from: components) else { return "Unknown Date" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    var body: some View {
        VStack(spacing: 0) {
            DayHeader(
                date: formattedDate(from: entry.key),
                amount: netExpense
            )
            ForEach(entry.value) { e in
                Group {
                    // 1. Compute the sub-expressions first
                    let matchedAccountName = (viewModel.accounts.first(where: { $0.id == e.accountId })?.name) ?? "Account"

                    let defaultCategory = Category(id: UUID(), name: "Uncategorized", userId: UUID(), iconName: "questionmark", colorHex: "#CCCCCC", entryType: e.type)
                    let matchedCategory = viewModel.categories.first(where: { $0.id == e.categoryId }) ?? defaultCategory

                    // 2. Pass those clean variables into the view
                    NavigationLink(value: e) {
                        EntryRow(
                            description: e.name,
                            account: matchedAccountName,
                            amount: e.amount,
                            type: e.type,
                            category: matchedCategory
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.bottom, 5)
    }
}

#Preview {
    DashboardView()
}
