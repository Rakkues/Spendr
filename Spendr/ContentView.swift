//
//  ContentView.swift
//  Spendr
//
//  Created by Anas Azman on 08/04/2026.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
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
    }
}

#Preview {
    ContentView()
}
