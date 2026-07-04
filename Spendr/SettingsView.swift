//
//  SettingsView.swift
//  Spendr
//
//  Created by Anas Azman on 15/04/2026.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.crust)
                    .ignoresSafeArea()

                List {
                    Section(header: Text("Account Settings")) {
                        // 2. Wrap each row in a NavigationLink with its destination view
                        NavigationLink(destination: ManageAccountsView()) {
                            Label("Accounts", systemImage: "creditcard")
                        }

                        NavigationLink(destination: ManageCategoriesView()) {
                            Label("Categories", systemImage: "tag")
                        }

                        NavigationLink(destination: ManageBudgetsView()) {
                            Label("Budgets", systemImage: "chart.pie")
                        }
                    }
                    .listRowBackground(Color.base)

                    // 3. Put the button cleanly inside a final section or list row
                    Section {
                        Button(role: .destructive) {
                            Task {
                                await authViewModel.signOut()
                            }
                        } label: {
                            HStack {
                                Spacer()
                                Text("Sign Out")
                                Spacer()
                            }
                        }
                    }
                }
                .navigationTitle("Settings")
                .scrollContentBackground(.hidden)
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AuthViewModel()) // Pass a mock if needed
}
