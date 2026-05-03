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
    .init(name: "Food", amount: 120, color: .orange),
    .init(name: "Transport", amount: 60, color: .blue),
    .init(name: "Bills", amount: 90, color: .green)
]

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
            Entry(type: .income, date: Date().addingTimeInterval(-10800), amount: 200.0, category: salary, name: "Freelance", account: "Bank Account")
        ]
    }

    private var groupedEntries: [DateComponents: [Entry]] {
        Dictionary(grouping: sampleEntries) { entry in
            Calendar.current.dateComponents([.day, .year, .month], from: entry.date)
        }
    }

    var body: some View {
        GeometryReader { geometry in
            let topInset = geometry.safeAreaInsets.top

            VStack(spacing: 0) {
                if !isExpanded {
                    ZStack {
                        // Placeholder for Pie Chart view
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.gray.opacity(0.12))
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

                Button(action: {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                        isExpanded.toggle()
                    }
                }) {
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.up")
                        .font(.headline)
                        .padding(8)
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.2))
                        .accessibilityLabel(isExpanded ? "Collapse" : "Expand")
                }

                ScrollView {
                    VStack(spacing: 5) {
                        DayHeader(date: "15th January", amount: 150.00)
                        ForEach(sampleEntries.indices, id: \.self) { idx in
                            let e = sampleEntries[idx]
                            EntryRow(description: e.name, account: e.account, amount: e.amount)
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
    }
}

struct DayHeader: View {
    let date: String
    let amount: Float

    var body: some View {
        HStack {
            Text(date)
            Spacer()
            Text(amount, format: .currency(code: "MYR"))
        }
        .padding()
        .background(Color.gray)
    }
}

struct EntryRow: View {
    let description: String
    let account: String
    let amount: Float

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
            Text(amount, format: .currency(code: "MYR"))
                .padding()
        }
        .padding(5)
        .background(Color.gray)
    }
}

#Preview {
    DashboardView()
}
