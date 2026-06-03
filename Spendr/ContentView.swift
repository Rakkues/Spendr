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
    
    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
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
            
                    Tab("", systemImage: "plus", role: .search) {
                        AddEntryView(viewModel: addEntryViewModel)
                    }
                }
                .environmentObject(authViewModel)
            } else {
                LoginView(authViewModel: authViewModel)
            }
        }
      }
}

#Preview {
    ContentView()
}
