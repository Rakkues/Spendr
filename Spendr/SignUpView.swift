//
//  SignUpView.swift
//  Spendr
//
//  Created by Anas Azman on 19/05/2026.
//

import SwiftUI

struct SignUpView: View { // Reference to the shared auth view model for performing actions.
    @ObservedObject var authViewModel: AuthViewModel
    /// Local input state for the email field.
    @State private var email = ""
    /// Local input state for the password field.
    @State private var password = ""
    @State private var confirmPassword = ""

    @State private var errorMessage: String? = nil

    var body: some View {
        ZStack {
            Color.crust
                .ignoresSafeArea()
            VStack(spacing: 15) {
                Text("Sign Up for an Account")

                TextField("Email", text: $email)
                    .textFieldStyle(.plain)
                    .padding(10)
                    .background(Color.surface0)
                    .cornerRadius(8)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)

                SecureField("Password", text: $password)
                    .id("passwordField")
                    .textFieldStyle(.plain)
                    .padding(10)
                    .background(Color.surface0)
                    .cornerRadius(8)

                SecureField("Confirm Password", text: $confirmPassword)
                    .id("confirmPasswordField")
                    .textFieldStyle(.plain)
                    .padding(10)
                    .background(Color.surface0)
                    .cornerRadius(8)

                if let errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                        .font(.footnote)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                Button {
                    Task {
                        // Basic validation before attempting sign up
                        guard !email.isEmpty, !password.isEmpty else {
                            errorMessage = "Email and password are required."
                            return
                        }
                        guard authViewModel.isValidEmail(email) else {
                            errorMessage = "Please enter a valid email address"
                            return
                        }
                        guard password == confirmPassword else {
                            errorMessage = "Passwords do not match."
                            return
                        }
                        errorMessage = nil
                        await authViewModel.signUp(email: email, password: password)
                    }
                } label: {
                    Text("Sign Up")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.glassProminent)
            }
            .padding(20)
        }
    }
}

#Preview {
    let mock = AuthViewModel()
    SignUpView(authViewModel: mock)
}
