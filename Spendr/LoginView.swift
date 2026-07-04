//
//  LoginView.swift
//  Spendr
//
//  Created by Anas Azman on 18/05/2026.
//

import AuthenticationServices
import SwiftUI

/// Simple email/password sign-in and sign-up form.
struct LoginView: View {
    /// Reference to the shared auth view model for performing actions.
    @ObservedObject var authViewModel: AuthViewModel
    /// Local input state for the email field.
    @State private var email = ""
    /// Local input state for the password field.
    @State private var password = ""
    @State private var errorMessage: String? = nil
    var body: some View {
        NavigationStack {
            ZStack {
                Color.crust
                    .ignoresSafeArea()
                
                VStack(spacing: 15) {
                    Text("Login")
                        .dynamicTypeSize(.xxxLarge)
                    
                    TextField("Email", text: $email)
                        .textFieldStyle(.plain)
                        .padding(10)
                        .background(Color.surface0)
                        .cornerRadius(8)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)

                    // Capture the user's password.
                    SecureField("Password", text: $password)
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
                    
                    // Trigger sign-in using the provided credentials.
                    Button {
                        Task {
                            guard !email.isEmpty, !password.isEmpty else {
                                errorMessage = "Email and password are required."
                                return
                            }
                            guard authViewModel.isValidEmail(email) else {
                                errorMessage = "Please enter a valid email address"
                                return
                            }
                            errorMessage = nil
                            await authViewModel.signIn(email: email, password: password)
                            if !authViewModel.errorMessage.isEmpty {
                                errorMessage = authViewModel.errorMessage
                            }
                        }
                    } label: {
                        Text("Sign In")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.glassProminent)
                    
                    HStack {
                        Text("Don't have an account?")
                        NavigationLink("Sign Up") {
                            SignUpView(authViewModel: authViewModel)
                        }
                    }
                }
                .padding(20)
              }
            .background(Color.crust)
        }
    }
}

#Preview {
    let mock = AuthViewModel()
    LoginView(authViewModel: mock)
}
