//
//  DashboardView.swift
//  Spendr
//
//  Created by Anas Azman on 15/04/2026.
//

import SwiftUI

struct DashboardView: View {
    @State private var isExpanded = false

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                Text("Total spendings:")
                    .font(.headline)
                    .frame(height: geometry.size.height * (isExpanded ? 0.0 : 0.4))

                Button(action: {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                        isExpanded.toggle()
                    }
                }) {
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.up")
                        .font(.headline)
                        .padding(8)
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.2))
                        .accessibilityLabel(isExpanded ? "Collapse" : "Expand")
                }
                
                ScrollView {
                    VStack(spacing: 15) {
                        VStack {
                            DayHeader(date: "15th January", amount: 45)
                            Entry(description: "Dinner", account: "Bank Account", amount: 15)
                            Entry(description: "Dinner", account: "Bank Account", amount: 15)
                            Entry(description: "Dinner", account: "Bank Account", amount: 15)
                        }
                        VStack {
                            DayHeader(date: "15th January", amount: 45)
                            Entry(description: "Dinner", account: "Bank Account", amount: 15)
                            Entry(description: "Dinner", account: "Bank Account", amount: 15)
                            Entry(description: "Dinner", account: "Bank Account", amount: 15)
                        }
                        VStack {
                            DayHeader(date: "15th January", amount: 45)
                            Entry(description: "Dinner", account: "Bank Account", amount: 15)
                            Entry(description: "Dinner", account: "Bank Account", amount: 15)
                            Entry(description: "Dinner", account: "Bank Account", amount: 15)
                        }
                    }
                }
                .frame(height: isExpanded ? geometry.size.height : geometry.size.height * 0.6)
                .contentShape(Rectangle())
                .frame(maxWidth: .infinity)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .animation(.spring(response: 0.35, dampingFraction: 0.85), value: isExpanded)
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

struct DayHeader: View {
    let date: String
    let amount: Float

    var body: some View {
        HStack {
            Text(date)
            Spacer()
            Text(amount, format: .currency(code: "MYR"))
        }
        .padding()
        .background(Color.gray)
    }
}

struct Entry: View {
    let description: String
    let account: String
    let amount: Float
    
    var body: some View {
        HStack {
            ZStack {
                Circle()
                    .scale(1)
                    .fill(Color.blue)
                Image(systemName: "fork.knife")
            }
            .frame(maxWidth: 75)
            VStack(alignment: .leading) {
                Text(description)
                Text(account)
                    .font(.system(size: 11))
            }
            Spacer()
            Text(amount, format: .currency(code: "MYR"))
                .padding()
        }
    }
}

#Preview {
    DashboardView()
}
