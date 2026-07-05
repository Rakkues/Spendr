//
//  EditBudgetSheet.swift
//  Spendr
//
//  Created by Anas Azman on 05/07/2026.
//

import SwiftUI

struct EditBudgetSheet: View {
    let category: Category
    let currentBudget: Budget?
    let onSave: (Double) -> Void
    let onDelete: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var amountString = ""
    @State private var errorMessage: String? = nil
    
    init(category: Category, currentBudget: Budget?, onSave: @escaping (Double) -> Void, onDelete: @escaping () -> Void) {
        self.category = category
        self.currentBudget = currentBudget
        self.onSave = onSave
        self.onDelete = onDelete
        
        // Pre-populate budget amount if it exists
        if let currentBudget = currentBudget {
            _amountString = State(initialValue: String(format: "%.2f", currentBudget.amount))
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.crust
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Category Info row
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Category")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            ZStack {
                                Circle()
                                    .fill(Color(hex: category.colorHex))
                                    .frame(width: 40, height: 40)
                                Image(systemName: category.iconName)
                                    .foregroundColor(.white)
                            }
                            
                            Text(category.name)
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Spacer()
                        }
                        .padding()
                        .background(Color.surface0)
                        .cornerRadius(12)
                    }
                    
                    // Amount Input
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Monthly Limit")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            Text("RM")
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                            
                            TextField("0.00", text: $amountString)
                                .textFieldStyle(.plain)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.leading)
                        }
                        .padding()
                        .background(Color.surface0)
                        .cornerRadius(12)
                    }
                    
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    Spacer()
                    
                    // Action Buttons
                    VStack(spacing: 12) {
                        Button {
                            // Basic validation
                            let cleaned = amountString.trimmingCharacters(in: .whitespacesAndNewlines)
                            guard let amount = Double(cleaned), amount > 0 else {
                                errorMessage = "Please enter a valid amount greater than zero."
                                return
                            }
                            
                            onSave(amount)
                            dismiss()
                        } label: {
                            Text(currentBudget == nil ? "Create Budget" : "Save Changes")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                        }
                        .padding(.vertical, 15)
                        .buttonStyle(.glassProminent)
                        .controlSize(.large)
                        
                        if currentBudget != nil {
                            Button(role: .destructive) {
                                onDelete()
                                dismiss()
                            } label: {
                                Text("Delete Budget")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.red)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                            }
                        }
                    }
                }
                .padding(20)
            }
            .navigationTitle(currentBudget == nil ? "Set Budget" : "Edit Budget")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}
