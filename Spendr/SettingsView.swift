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
                        NavigationLink(destination: ManageAccountsView()) {
                            Label("Accounts", systemImage: "creditcard")
                        }

                        NavigationLink(destination: ManageBudgetsView()) {
                            Label("Budgets", systemImage: "chart.pie")
                        }
                    }
                    .listRowBackground(Color.base)

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
