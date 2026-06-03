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
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                }
                .buttonStyle(.glass)
                .padding(.leading, 20)
                
                Spacer()
                
                Text("Add New Entry")
                    .font(.headline)
                
                Spacer()
                
                Color.clear
                    .frame(width: 44, height: 44)
                    .padding(.trailing, 20)
            }
            .frame(height: 44)
            .padding(.vertical, 0)
            .contentShape(Rectangle())
            
            // Entry type selector
            Picker("Entry Type", selection: $viewModel.type) {
                ForEach(EntryType.allCases, id: \.self) { entryType in
                    Text(entryType.rawValue)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.vertical, 15)

            // Form container
            ScrollView {
                VStack(spacing: 30) {
                    DatePicker("Date", selection: $viewModel.date, displayedComponents: [.date])

                    HStack {
                        Text("Amount")
                        Spacer()
                        TextField("", value: $viewModel.amount, formatter: viewModel.doubleFormatter)
                            .frame(maxWidth: 250)
                            .textFieldStyle(.roundedBorder)
                            .multilineTextAlignment(.trailing)
                    }

                    HStack {
                        Text("Account")
                        Spacer()
                        Picker("Account", selection: $viewModel.selectedAccount) {
                            Text("Select an account").tag(nil as Account?)
                            ForEach(viewModel.accounts) { account in
                                Text(account.name)
                                    .tag(account as Account?)
                            }
                        }
                        .pickerStyle(.menu)
                        .buttonStyle(.bordered)
                    }

                    HStack {
                        Text("Category")
                        Spacer()
                        Picker("Category", selection: $viewModel.selectedCategory) {
                            Text("Select a category").tag(nil as Category?)
                            ForEach(viewModel.categories) { category in
                                Text(category.name)
                                    .tag(category as Category?)
                            }
                        }
                        .pickerStyle(.menu)
                        .buttonStyle(.bordered)
                    }

                    HStack {
                        Text("Name")
                        Spacer()
                        TextField("", text: $viewModel.name)
                            .frame(maxWidth: 250)
                            .textFieldStyle(.roundedBorder)
                            .multilineTextAlignment(.trailing)
                    }
                }
                .padding(20)
                .background(Color.base)
            }
            
            // --- 4. ACTION ACTION BUTTON ---
            Button(action: addEntry) {
                Label("Add Entry", systemImage: "plus")
                    .frame(maxWidth: 300)
            }
            .padding(.vertical, 15)
            .buttonStyle(.glassProminent)
            .controlSize(.large)
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .task {
            await viewModel.fetchAccounts()
            await viewModel.fetchCategories()
        }
    }

    private func addEntry() {
        // Your logic to commit data to Supabase
    }
}

#Preview {
    let mock = AddEntryViewModel()
    AddEntryView(viewModel: mock)
}
