//
//  AddEntryView.swift
//  Spendr
//
//  Created by Anas Azman on 12/05/2026.
//

import SwiftUI

struct AddEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: AddEntryViewModel
    @State private var selectedCategory: Category?

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

            Picker("Entry Type", selection: $viewModel.type) {
                ForEach(EntryType.allCases, id: \.self) { entryType in
                    Text(entryType.rawValue)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.vertical, 10)

            VStack(spacing: 30) {
                DatePicker("Date", selection: $viewModel.date, displayedComponents: [.date])

                HStack {
                    Text("Name")
                    Spacer()
                    TextField("", text: $viewModel.name)
                        .frame(maxWidth: 270)
                }

                HStack {
                    Text("Account")
                    Spacer()
                    TextField("", text: $viewModel.account)
                        .frame(maxWidth: 270)
                }

                HStack {
                    Text("Amount")
                    Spacer()
                    TextField("", value: $viewModel.amount, formatter: viewModel.doubleFormatter)
                        .frame(maxWidth: 270)
                }

                HStack {
                    Text("Category")
                    Spacer()
                    Picker("Category", selection: $selectedCategory) {
                        // 1. Show a placeholder if no data is loaded yet
                        if viewModel.categories.isEmpty {
                            Text("Loading categories...").tag(nil as Category?)
                        } else {
                            Text("Select a category").tag(nil as Category?)
                        }

                        // 2. Loop through the fetched categories
                        ForEach(viewModel.categories) { category in
                            Text(category.name)
                                .tag(category as Category?) // Tag allows SwiftUI to track selection
                        }
                    }
                    .pickerStyle(.menu) // Makes it look like a standard iOS dropdown menu
                    .buttonStyle(.bordered) // Gives the dropdown a clean, tappable border
                }
                .task {
                    await viewModel.fetchCategories()
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
    let mock = AddEntryViewModel()
    AddEntryView(viewModel: mock)
}
