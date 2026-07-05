//
//  EditAccountSheet.swift
//  Spendr
//
//  Created by Anas Azman on 05/07/2026.
//

import SwiftUI

struct EditAccountSheet: View {
    let currentAccount: Account?
    let onSave: (String) -> Void
    let onDelete: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var errorMessage: String? = nil
    
    init(currentAccount: Account?, onSave: @escaping (String) -> Void, onDelete: @escaping () -> Void) {
        self.currentAccount = currentAccount
        self.onSave = onSave
        self.onDelete = onDelete
        
        if let currentAccount = currentAccount {
            _name = State(initialValue: currentAccount.name)
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.crust
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Account Name Input
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Account Name")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        TextField("e.g. Checking Account, Cash", text: $name)
                            .padding()
                            .background(Color.surface0)
                            .cornerRadius(12)
                            .textFieldStyle(.plain)
                    }
                    
                    // Currency Field (Hardcoded, no input field)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Currency")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            Text("MYR")
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                            
                            Spacer()
                            
                            Text("Default Malaysian Ringgit")
                                .font(.footnote)
                                .foregroundColor(.secondary)
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
                            let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
                            guard !trimmed.isEmpty else {
                                errorMessage = "Account name cannot be empty."
                                return
                            }
                            
                            onSave(trimmed)
                            dismiss()
                        } label: {
                            Text(currentAccount == nil ? "Create Account" : "Save Changes")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                        }
                        .padding(.vertical, 15)
                        .buttonStyle(.glassProminent)
                        .controlSize(.large)
                        
                        if currentAccount != nil {
                            Button(role: .destructive) {
                                onDelete()
                                dismiss()
                            } label: {
                                Text("Delete Account")
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
            .navigationTitle(currentAccount == nil ? "New Account" : "Edit Account")
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
