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
        Text("Sign Up for an Account")
        VStack {
            TextField("Email", text: $email)
                .textFieldStyle(.roundedBorder)
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)

            SecureField("Password", text: $password)
                .id("passwordField")
                .textFieldStyle(.roundedBorder)

            SecureField("Confirm Password", text: $confirmPassword)
                .id("confirmPasswordField")
                .textFieldStyle(.roundedBorder)

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
            .buttonStyle(.borderedProminent)
        }
        .padding(20)
    }
}

#Preview {
    let mock = AuthViewModel()
    SignUpView(authViewModel: mock)
}
