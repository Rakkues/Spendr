//
//  SettingsView.swift
//  Spendr
//
//  Created by Anas Azman on 15/04/2026.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        Button {
            Task {
                await authViewModel.signOut()
            }
        } label: {
            Text("Sign Out")
                .frame(maxWidth: 300)
        }
        .buttonStyle(.glass)
        .foregroundStyle(Color.red)
       }
}

#Preview {
    SettingsView()
}
