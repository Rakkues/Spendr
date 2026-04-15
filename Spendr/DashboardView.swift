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
                        ForEach(0..<20) { i in
                            Text("Entry \(i)")
                        }
                    }
                    .padding()
                }
                .frame(height: geometry.size.height * 0.6)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}


#Preview {
    DashboardView()
}
