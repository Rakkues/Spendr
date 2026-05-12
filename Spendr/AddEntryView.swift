//
//  AddEntryView.swift
//  Spendr
//
//  Created by Anas Azman on 12/05/2026.
//

import SwiftUI

struct AddEntryView: View {
    
    var body: some View {
        Form {
            // Type (Static)
            HStack {
                Text("Type")
                Spacer()
                Text("Expense")
                    .foregroundColor(.secondary)
            }

            // Date (Static)
            HStack {
                Text("Date")
                Spacer()
                Text(Date.now, style: .date)
                    .foregroundColor(.secondary)
            }

            // Name (Static)
            HStack {
                Text("Name")
                Spacer()
                Text("Coffee")
                    .foregroundColor(.secondary)
            }

            // Account (Static)
            HStack {
                Text("Account")
                Spacer()
                Text("Cash")
                    .foregroundColor(.secondary)
            }

            // Amount (Static)
            HStack {
                Text("Amount")
                Spacer()
                Text("12.00")
                    .foregroundColor(.secondary)
            }

            // Category Placeholder (Static)
            HStack {
                Text("Category")
                Spacer()
                Text("Select category")
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    AddEntryView()
}
