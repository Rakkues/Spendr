//
//  DashboardView.swift
//  Spendr
//
//  Created by Anas Azman on 15/04/2026.
//

import Charts
import SwiftUI

struct CategorySlice: Identifiable {
    let id = UUID()
    let name: String
    let amount: Double
    let color: Color
}

private let sampleSlices: [CategorySlice] = [
    .init(name: "Food", amount: 120, color: .flamingo),
    .init(name: "Transport", amount: 60, color: .maroon),
    .init(name: "Bills", amount: 90, color: .mauve)
]

struct DayEntries {
    let entries: [Entry]
    let netExpense: Double
}

struct DashboardView: View {
    @State private var isExpanded = false

    let food = Category(name: "Food", iconName: "fork.knife", colorHex: "#FF9500")
    let transport = Category(name: "Transport", iconName: "tram.fill", colorHex: "#0A84FF")
    let bills = Category(name: "Bills", iconName: "bolt.fill", colorHex: "#34C759")
    let salary = Category(name: "Salary", iconName: "creditcard.fill", colorHex: "#AF52DE")

    private var sampleEntries: [Entry] {
        [
            Entry(type: .expense, date: Date(), amount: 15.0, category: food, name: "Dinner", account: "Bank Account"),
            Entry(type: .expense, date: Date().addingTimeInterval(-3600), amount: 8.5, category: transport, name: "Bus", account: "Cash"),
            Entry(type: .expense, date: Date().addingTimeInterval(-7200), amount: 45.0, category: bills, name: "Electricity", account: "Bank Account"),
            Entry(type: .income, date: Date().addingTimeInterval(-10800), amount: 200.0, category: salary, name: "Freelance", account: "Bank Account"),
            Entry(type: .income, date: Date().addingTimeInterval(-30000), amount: 500.0, category: salary, name: "Freelance", account: "Bank Account"),
            Entry(type: .income, date: Date().addingTimeInterval(-100000), amount: 500.0, category: salary, name: "Freelance", account: "Bank Account")
        ]
    }

    private var groupedEntries: [DateComponents: DayEntries] {
        let grouped = Dictionary(grouping: sampleEntries) { entry in
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
            let topInset = geometry.safeAreaInsets.top

            VStack(spacing: 0) {
                if !isExpanded {
                    // Pie chart
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.crust)
                            .overlay(
                                VStack(spacing: 8) {
                                    Text("Spending Distribution")
                                        .font(.headline)
                                    Chart(sampleSlices) { slice in
                                        SectorMark(
                                            angle: .value("Amount", slice.amount),
                                            innerRadius: .ratio(0.6)
                                        )
                                        .foregroundStyle(slice.color)
                                    }
                                    .frame(height: 180)
                                }
                                .padding()
                            )
                    }
                    .frame(height: geometry.size.height * 0.3)
                }

                // Expand list button
                Button(action: {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                        isExpanded.toggle()
                    }
                    print(groupedEntries)
                }) {
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.up")
                        .font(.headline)
                        .padding(8)
                        .frame(maxWidth: .infinity)
                        .background(Color.surface1)
                        .accessibilityLabel(isExpanded ? "Collapse" : "Expand")
                }

                // Date entries
                ScrollView {
                    VStack(spacing: 5) {
                        ForEach(groupedEntries.sorted(by: { lhs, rhs in
                            let lhsDate = Calendar.current.date(from: lhs.key) ?? Date.distantPast
                            let rhsDate = Calendar.current.date(from: rhs.key) ?? Date.distantPast
                            return lhsDate > rhsDate
                        }), id: \.key) { dateComponents, dayEntries in
                            DateEntries(entry: (key: dateComponents, value: dayEntries.entries), netExpense: dayEntries.netExpense)
                        }
                    }
                }
                .frame(height: isExpanded ? geometry.size.height - topInset : geometry.size.height * 0.6)
                .contentShape(Rectangle())
                .frame(maxWidth: .infinity)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .animation(.spring(response: 0.35, dampingFraction: 0.85), value: isExpanded)
        }
        .ignoresSafeArea(edges: .bottom)
        .background(Color.base)
        .foregroundColor(.text)
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

    var body: some View {
        HStack {
            ZStack {
                Circle()
                    .scale(1)
                    .fill(Color.blue)
                Image(systemName: "fork.knife")
            }
            .frame(maxWidth: 75)
            VStack(alignment: .leading) {
                Text(description)
                Text(account)
                    .font(.system(size: 11))
            }
            Spacer()

            switch type {
            case .income:
                Text(amount, format: .currency(code: "MYR"))
                    .padding()
                    .foregroundStyle(Color.sky)
            case .expense:
                Text(-amount, format: .currency(code: "MYR"))
                    .padding()
                    .foregroundStyle(Color.catRed)
            case .transfer:
                Text(amount, format: .currency(code: "MYR"))
                    .padding()
                    .foregroundStyle(Color.catGreen)
            }
        }
        .padding(5)
        .background(Color.surface1)
    }
}

struct DateEntries: View {
    let entry: (key: DateComponents, value: [Entry])
    let netExpense: Double

    private func formattedDate(from components: DateComponents) -> String {
        guard let date = Calendar.current.date(from: components) else { return "Unknown Date" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    var body: some View {
        VStack(spacing: 5) {
            DayHeader(
                date: formattedDate(from: entry.key),
                amount: netExpense
            )
            ForEach(entry.value.indices, id: \.self) { idx in
                let e = entry.value[idx]
                EntryRow(description: e.name, account: e.account, amount: Double(e.amount), type: e.type)
            }
        }
    }
}

#Preview {
    DashboardView()
}
