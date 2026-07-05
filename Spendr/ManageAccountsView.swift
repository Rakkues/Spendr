//
//  ManageAccountsView.swift
//  Spendr
//
//  Created by Anas Azman on 04/07/2026.
//

import SwiftUI

struct ManageAccountsView: View {
    @StateObject private var viewModel = ManageAccountsViewModel()
    @State private var selectedAccount: Account? = nil
    @State private var isShowingSheet = false
    
    var body: some View {
        ZStack {
            Color.crust
                .ignoresSafeArea()
            
            Group {
                if viewModel.isLoading && viewModel.accounts.isEmpty {
                    ProgressView("Loading Accounts...")
                        .tint(.primary)
                } else if viewModel.accounts.isEmpty {
                    ContentUnavailableView(
                        "No Accounts Yet",
                        systemImage: "creditcard",
                        description: Text("Add a checking or savings account to start tracking your balance.")
                    )
                } else {
                    List {
                        Section(header: Text("Financial Accounts")) {
                            ForEach(viewModel.accounts) { account in
                                Button {
                                    selectedAccount = account
                                    isShowingSheet = true
                                } label: {
                                    HStack {
                                        Label(account.name, systemImage: "creditcard.fill")
                                            .foregroundColor(.primary)
                                        
                                        Spacer()
                                        
                                        Text(account.currencyCode)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.footnote)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                        .listRowBackground(Color.base)
                    }
                    .scrollContentBackground(.hidden)
                }
            }
        }
        .navigationTitle("Manage Accounts")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    selectedAccount = nil
                    isShowingSheet = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .task {
            await viewModel.fetchAccounts()
        }
        .sheet(isPresented: $isShowingSheet) {
            EditAccountSheet(currentAccount: selectedAccount) { name in
                Task {
                    await viewModel.saveAccount(name: name, currentAccount: selectedAccount)
                }
            } onDelete: {
                Task {
                    if let account = selectedAccount {
                        await viewModel.deleteAccount(account)
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ManageAccountsView()
    }
}
