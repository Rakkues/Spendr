//
//  DashboardView.swift
//  Spendr
//
//  Created by Anas Azman on 15/04/2026.
//

import SwiftUI

struct DashboardView: View {
    var body: some View {
        GeometryReader {
            geometry in VStack(spacing: 0) {
                VStack {
                    Text("Total spendings:")
                        .font(.headline)
                }
                .frame(height: geometry.size.height * 0.4)

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
                .frame(maxWidth: .infinity)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
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
