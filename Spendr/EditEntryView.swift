//
//  EditEntryView.swift
//  Spendr
//
//  Created by Anas Azman on 29/06/2026.
//

import SwiftUI

struct EditEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: EditEntryViewModel

    @State private var showAccountError = false
    @State private var showCategoryError = false
    @State private var showToAccountError = false
    @State private var showAmountError = false
    @State private var showNameError = false

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Spacer()
                Text("Edit Entry")
                    .font(.headline)
                Spacer()
            }
            .frame(height: 44)
            .padding(.vertical, 0)
            .contentShape(Rectangle())

            // Entry type selector
            Picker("Entry Type", selection: $viewModel.type) {
                ForEach([EntryType.expense, EntryType.income], id: \.self) { entryType in
                    Text(entryType.displayName)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.vertical, 15)

            ScrollView {
                VStack(spacing: 20) {
                    DatePicker("Date", selection: $viewModel.date, displayedComponents: [.date])
                        .environment(\.timeZone, TimeZone(secondsFromGMT: 0)!)

                    HStack {
                        Text("Amount")
                        Spacer()
                        HStack {
                            Text(viewModel.selectedAccount?.currencyCode ?? "Currency")
                                .foregroundStyle(.blue)
                            TextField("", value: $viewModel.amount, formatter: viewModel.doubleFormatter)
                                .textFieldStyle(.roundedBorder)
                                .multilineTextAlignment(.trailing)
                        }
                        .frame(maxWidth: 250)
                    }
                    if showAmountError {
                        Text("Amount must be greater than zero.")
                            .font(.caption2)
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.top, -10)
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
                    if showAccountError {
                        Text("Please select an account.")
                            .font(.caption2)
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.top, -10)
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
                    if showCategoryError {
                        Text("Please select a category.")
                            .font(.caption2)
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.top, -10)
                    }

                    HStack {
                        Text("Name")
                        Spacer()
                        TextField("", text: $viewModel.name)
                            .frame(maxWidth: 250)
                            .textFieldStyle(.roundedBorder)
                            .multilineTextAlignment(.trailing)
                    }
                    if showNameError {
                        Text("Please enter a name.")
                            .font(.caption2)
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.top, -10)
                    }
                }
                .padding(20)
                .background(Color.base)
            }
            // Form container
            Button {
                Task {
                    await viewModel.updateEntry()

                    if viewModel.errorMessage == nil {
                        dismiss()
                    }
                }
            } label: {
                Label("Confirm", systemImage: "plus")
            }
            .padding(.vertical, 15)
            .buttonStyle(.glassProminent)
            .controlSize(.large)
        }
        .background(Color.crust)
        .frame(maxHeight: .infinity, alignment: .top)
        .onChange(of: viewModel.type) {
            viewModel.selectedCategory = nil
            showAccountError = false
            showCategoryError = false
            showToAccountError = false
            showAmountError = false
            showNameError = false
        }
        .onChange(of: viewModel.selectedAccount) {
            showAccountError = false
        }
        .onChange(of: viewModel.selectedCategory) {
            showCategoryError = false
        }
        .onChange(of: viewModel.amount) {
            showAmountError = false
        }
        .onChange(of: viewModel.name) {
            showNameError = false
        }
        .task(id: viewModel.type) {
            await viewModel.loadFormData()
        }
    }
}

#Preview {
//    let mock = EditEntryViewModel()
//    EditEntryView(viewModel: mock)
}
