//
//  AuthViewModel.swift
//  Spendr
//
//  Created by Anas Azman on 18/05/2026.
//

import Combine
import Foundation
import Supabase
import SwiftUI

/// View model responsible for handling authentication state and actions using Supabase.
@MainActor
class AuthViewModel: ObservableObject {
    /// The current authenticated session if available. Nil when logged out or pending email confirmation.
    @Published var session: Session?
    /// Convenience flag derived from whether a valid session exists.
    @Published var isAuthenticated = false
    /// Prevents duplicate requests while an auth operation is in flight.
    @Published var isLoading = false
    @Published var errorMessage = ""
    
    func getInitialSession() async {
        // Continuous listener stream to capture the session immediately when local storage becomes ready
        // and catch subsequent state changes (token refreshes, sign outs, etc.)
        for await authState in supabase.auth.authStateChanges {
            let current = authState.session
            self.session = current
            self.isAuthenticated = current != nil
                
            print("Auth state updated stream: session is \(current == nil ? "nil" : "present"), isAuthenticated: \(self.isAuthenticated)")
        }
    }
    
    func signUp(email: String, password: String) async {
        // Create a new user account. Depending on Supabase settings, email confirmation may be required.
        do {
            // Debounce repeated taps while a request is already in progress.
            guard !self.isLoading else { return }
            self.isLoading = true
            defer { isLoading = false }

            // Perform sign-up; response.session can be nil if email confirmation is enabled.
            let response = try await supabase.auth.signUp(email: email, password: password)
            // Persist the returned session (if any) and update auth state.
            self.session = response.session
            self.isAuthenticated = self.session != nil
            // Keep the previous logging style for consistency (will be "present" on success).
            print("SignUp: session is \(self.session == nil ? "nil" : "present")")
        } catch {
            // Surface a readable error and reset state on failure.
            print("Sign-up failed: \(error.localizedDescription)")
            self.session = nil
            self.isAuthenticated = false
        }
    }
    
    func signIn(email: String, password: String) async {
        // Sign in an existing user with email/password and update session.
        do {
            // Avoid overlapping sign-in attempts.
            guard !self.isLoading else { return }
            self.isLoading = true
            defer { isLoading = false }

            // On success, Supabase returns a non-optional Session.
            let session = try await supabase.auth.signIn(email: email, password: password)
            // Store the active session so the UI can react.
            self.session = session
            // Mark the user as authenticated since sign-in succeeded.
            self.isAuthenticated = true
            // Keep the previous logging style for consistency (will be "present" on success).
            print("SignIn: session is \(self.session == nil ? "nil" : "present")")
            
            try await supabase
                .rpc("seed_user_defaults", params: ["authenticated_user_id": session.user.id])
                .execute()
                        
            print("Database seeding verification complete.")
            
        } catch {
            // Reset to a clean unauthenticated state if sign-in fails.
            print("Sign-in failed: \(error.localizedDescription)")
            self.errorMessage = error.localizedDescription
            self.session = nil
            self.isAuthenticated = false
        }
    }
    
    func signOut() async {
        // Clear the server-side session and update local state.
        do {
            try await supabase.auth.signOut()
            self.session = nil
            self.isAuthenticated = false
        } catch {
            // Log sign-out errors but keep the UI responsive.
            print("Sign-out failed: \(error.localizedDescription)")
        }
    }
}
