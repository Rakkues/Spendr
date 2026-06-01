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
    var body: some View {
        NavigationStack {
            VStack(spacing: 15) {
                Text("Login")
                    .dynamicTypeSize(.xxxLarge)
                
                TextField("Email", text: $email)
                    .textFieldStyle(.roundedBorder)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                
                // Capture the user's password.
                SecureField("Password", text: $password)
                    .textFieldStyle(.roundedBorder)
                
                // Trigger sign-in using the provided credentials.
                Button {
                    Task {
                        await authViewModel.signIn(email: email, password: password)
                    }
                } label: {
                    Text("Sign In")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.glassProminent)
               }
            .padding(20)
            HStack {
                Text("Don't have an account?")
                NavigationLink("Sign Up") {
                    SignUpView(authViewModel: authViewModel)
                }
             }
        }
    }
}

#Preview {
    let mock = AuthViewModel()
    LoginView(authViewModel: mock)
}
