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
                ZStack(alignment: .bottom) {
                    TabView {
                        Tab("Dashboard", systemImage: "house") {
                            NavigationStack {
                                DashboardView()
                            }
                        }

                        Tab("Statistics", systemImage: "chart.bar.fill") {
                            NavigationStack {
                                StatisticsView()
                            }
                        }

                        Tab("Settings", systemImage: "gear") {
                            NavigationStack {
                                SettingsView()
                            }
                        }
                    }
                    .environmentObject(authViewModel)

                    HStack {
                        Spacer()
                        Button(action: {
                            navigateToAddEntry = true
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
                .sheet(isPresented: $navigateToAddEntry) {
                    NavigationStack {
                        AddEntryView(viewModel: addEntryViewModel)
                    }
                }
            } else {
                LoginView(authViewModel: authViewModel)
            }
        }
        .task {
            await authViewModel.getInitialSession()
        }
    }
}

#Preview {
    ContentView()
}
