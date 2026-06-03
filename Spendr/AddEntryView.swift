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

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                // 1. Left Aligned Back Button
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                }
                .controlSize(.large)
                .buttonStyle(.glass)
                .padding(.leading, 20) // Kept your spacing here
                
                Spacer() // Pushes the title to the center
                
                // 2. Centered Title
                Text("Add New Entry")
                    .font(.headline)
                
                Spacer() // Pushes the title from the right side
                
                // 3. Invisible frame matching the button's width to keep the title perfectly centered
                Color.clear
                    .frame(width: 44, height: 44) // Standard tap target size matching your button
                    .padding(.trailing, 20)
            }
            .frame(height: 44) // Clean, explicit height for a navigation bar header
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
                    Text("Amount")
                    Spacer()
                    TextField("", value: $viewModel.amount, formatter: viewModel.doubleFormatter)
                        .frame(maxWidth: 270)
                }

                HStack {
                    Text("Account")
                    Spacer()
                    Picker("Account", selection: $viewModel.selectedAccount) {
                        // 1. Show a placeholder if no data is loaded yet
                        if viewModel.categories.isEmpty {
                            Text("Loading accounts...").tag(nil as Account?)
                        } else {
                            Text("Select an account").tag(nil as Account?)
                        }

                        // 2. Loop through the fetched categories
                        ForEach(viewModel.accounts) { account in
                            Text(account.name)
                                .tag(account as Account?) // Tag allows SwiftUI to track selection
                        }
                    }
                    .pickerStyle(.menu) // Makes it look like a standard iOS dropdown menu
                    .buttonStyle(.bordered) // Gives the dropdown a clean, tappable border
                }
                .task {
                    await viewModel.fetchAccounts()
                }

                HStack {
                    Text("Category")
                    Spacer()
                    Picker("Category", selection: $viewModel.selectedCategory) {
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

                HStack {
                    Text("Name")
                    Spacer()
                    TextField("", text: $viewModel.name)
                        .frame(maxWidth: 270)
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
