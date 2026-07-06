//
//  LocationPermissionBanner.swift
//  Whats REAL
//
//  Created by Sai Suman Pothedar on 4/6/26.
//

import SwiftUI
import CoreLocation

/// Banner prompting for location permission
struct LocationPermissionBanner: View {
    let onRequestPermission: () -> Void
    @State private var isDismissed = false
    
    var body: some View {
        if !isDismissed {
            HStack(spacing: 12) {
                Image(systemName: "location.fill")
                    .font(.title3)
                    .foregroundStyle(.blue)

                VStack(alignment: .leading, spacing: 3) {
                    Text("Location Access Needed")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                    Text("See questions near you")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button {
                    onRequestPermission()
                    isDismissed = true
                } label: {
                    Text("Enable")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 3)
            .padding(.horizontal)
            .padding(.top, 6)
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }
}

#Preview {
    LocationPermissionBanner(onRequestPermission: {})
}
