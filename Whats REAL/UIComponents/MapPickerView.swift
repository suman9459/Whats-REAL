//
//  MapPickerView.swift
//  Whats REAL
//

import SwiftUI
import MapKit

/// Full-screen map where the user drags to position a center pin.
/// On drag stop, reverse-geocodes the pin coordinate and shows a confirm card.
struct MapPickerView: View {
    let onSelect: (WRPlace) -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var camera: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var resolvedPlace: WRPlace?
    @State private var isGeocoding = false
    @State private var geocodeTask: Task<Void, Never>?

    var body: some View {
        ZStack {
            Map(position: $camera)
                .onMapCameraChange(frequency: .onEnd) { context in
                    scheduleGeocode(for: context.region.center)
                }
                .ignoresSafeArea()

            // Fixed center pin — stays stationary while map moves beneath it
            VStack(spacing: 0) {
                Image(systemName: "mappin.circle.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(.red)
                    .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                // Pin shadow dot
                Ellipse()
                    .fill(.black.opacity(0.15))
                    .frame(width: 14, height: 6)
                    .blur(radius: 2)
            }
            .allowsHitTesting(false)

            // Bottom confirm card
            VStack {
                Spacer()

                VStack(alignment: .leading, spacing: 12) {
                    if isGeocoding {
                        HStack {
                            ProgressView()
                            Text("Finding address…")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                    } else if let place = resolvedPlace {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(place.name)
                                .font(.headline)
                                .lineLimit(1)
                            Text(place.address)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                        }

                        Button {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            onSelect(place)
                            dismiss()
                        } label: {
                            Text("Confirm Location")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.blue)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    } else {
                        Text("Move the map to pin a location")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
                .padding()
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
                .padding(.horizontal, 16)
                .padding(.bottom, 32)
            }
        }
        .navigationTitle("Pin Location")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
        }
    }

    private func scheduleGeocode(for coordinate: CLLocationCoordinate2D) {
        geocodeTask?.cancel()
        isGeocoding = true
        resolvedPlace = nil

        geocodeTask = Task {
            let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            let placemarks = try? await CLGeocoder().reverseGeocodeLocation(location)

            guard !Task.isCancelled else { return }
            isGeocoding = false

            if let placemark = placemarks?.first {
                resolvedPlace = WRPlace(
                    id: "\(coordinate.latitude)_\(coordinate.longitude)",
                    name: placemark.name ?? placemark.locality ?? "Pinned Location",
                    address: placemark.formattedAddress,
                    lat: coordinate.latitude,
                    lng: coordinate.longitude
                )
            }
        }
    }
}

#Preview {
    NavigationStack {
        MapPickerView { place in
            print("Selected: \(place.name)")
        }
    }
}
