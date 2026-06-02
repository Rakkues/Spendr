//
//  AddEntryView.swift
//  Spendr
//
//  Created by Anas Azman on 12/05/2026.
//

import SwiftUI

struct AddEntryView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var date = Date()
    @State private var name = ""
    @State private var type = "Expense"
    @State private var entryName = ""
    @State private var account = ""
    @State private var amount = 0.0

    private let entryTypes = ["Expense", "Income", "Transfer"]

    private var doubleFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter
    }

    var body: some View {
        VStack(spacing: 20) {
            Grid {
                GridRow {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                    }
                    .controlSize(.large)
                    .buttonStyle(.glass)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    
                    
                    Text("Add New Entry")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                    
                    Spacer()
                        .frame(maxWidth: .infinity)
                }
            }
            .frame(maxHeight: 20)
            .padding(.vertical, 5)

            Picker("Entry Type", selection: $type) {
                ForEach(entryTypes, id: \.self) { entryType in
                    Text(entryType)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.vertical, 10)

            VStack(spacing: 30) {
                DatePicker("Date", selection: $date, displayedComponents: [.date])

                HStack {
                    Text("Name")
                    Spacer()
                    TextField("", text: $name)
                        .frame(maxWidth: 270)
                }

                HStack {
                    Text("Account")
                    Spacer()
                    TextField("", text: $account)
                        .frame(maxWidth: 270)
                }

                HStack {
                    Text("Amount")
                    Spacer()
                    TextField("", value: $amount, formatter: doubleFormatter)
                        .frame(maxWidth: 270)
                }

                HStack {
                    Text("Category")
                    Spacer()
                    Text("Select category")
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(20)
            .background(Color.base)

            Button(action: addEntry) {
                Label("Add Entry", systemImage: "plus")
                    .frame(maxWidth: 300)
            }
            .padding(.top, 10)
            .buttonStyle(.glassProminent)
            .controlSize(.large)
        }
        .frame(maxHeight: .infinity, alignment: .top)
    }

    private func addEntry() {
        Task {}
    }
}

#Preview {
    AddEntryView()
}
