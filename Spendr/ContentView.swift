//
//  ContentView.swift
//  Spendr
//
//  Created by Anas Azman on 08/04/2026.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var addEntryViewModel = AddEntryViewModel()
    @State private var navigateToAddEntry = false

    private var isLoggedIn: Bool {
        let isXCodePreview = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"

        if isXCodePreview {
            return true // Always skip login inside the Xcode Preview canvas
        } else {
            return authViewModel.isAuthenticated // Enforce real login inside the Simulator or real device
        }
    }

    var body: some View {
        Group {
            if isLoggedIn {
                NavigationStack {
                    ZStack(alignment: .bottom) {
                        TabView {
                            Tab("Dashboard", systemImage: "house") {
                                DashboardView()
                            }

                            Tab("Statistics", systemImage: "chart.bar.fill") {
                                StatisticsView()
                            }

                            Tab("Settings", systemImage: "gear") {
                                SettingsView()
                            }
                        }
                        .environmentObject(authViewModel)

                        HStack {
                            Spacer()
                            Button(action: {
                                navigateToAddEntry = true // Triggers the overlay sheet
                            }) {
                                Image(systemName: "plus")
                                    .font(.title.bold())
                                    .foregroundColor(.white)
                                    .frame(width: 50, height: 50)
                                    .clipShape(Circle())
                            }
                            .padding(.trailing, 20)
                            .buttonStyle(.glassProminent)
                        }
                        .padding(.bottom, 60)
                    }
                    .navigationDestination(isPresented: $navigateToAddEntry) {
                        AddEntryView(viewModel: addEntryViewModel)
                            .toolbar(.hidden, for: .navigationBar) // Hides the default apple back button so yours works
                    }
                }
            } else {
                LoginView(authViewModel: authViewModel)
            }
        }
    }
}

#Preview {
    ContentView()
}
