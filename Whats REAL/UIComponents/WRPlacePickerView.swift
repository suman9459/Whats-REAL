//
//  WRPlacePickerView.swift
//  Whats REAL
//

import SwiftUI

struct WRPlacePickerView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: PlacePickerViewModel
    let onSelect: (WRPlace) -> Void

    @State private var showMapPicker = false

    init(placesService: PlacesServiceProtocol, onSelect: @escaping (WRPlace) -> Void) {
        _viewModel = StateObject(wrappedValue: PlacePickerViewModel(placesService: placesService))
        self.onSelect = onSelect
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)

                    TextField("Search for a place", text: $viewModel.searchText)
                        .textFieldStyle(.plain)
                        .autocorrectionDisabled()
                        .onChange(of: viewModel.searchText) { _, _ in
                            Task { await viewModel.onSearchTextChanged() }
                        }

                    if !viewModel.searchText.isEmpty {
                        Button {
                            viewModel.searchText = ""
                            viewModel.clearSearch()
                        } label: {
                            Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding()

                Divider()

                // Content
                Group {
                    if viewModel.isLoading {
                        ProgressView().padding()
                        Spacer()
                    } else if viewModel.places.isEmpty && !viewModel.searchText.isEmpty {
                        emptySearchView
                    } else {
                        placesList
                    }
                }
            }
            .navigationTitle("Select Place")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showMapPicker = true
                    } label: {
                        Label("Pin on Map", systemImage: "mappin.and.ellipse")
                    }
                }
            }
            .navigationDestination(isPresented: $showMapPicker) {
                MapPickerView { place in
                    onSelect(place)
                    dismiss()
                }
            }
            .task {
                await viewModel.loadNearby()
            }
        }
    }

    private var emptySearchView: some View {
        VStack {
            VStack(spacing: 12) {
                Image(systemName: "mappin.slash").font(.largeTitle).foregroundStyle(.secondary)
                Text("No places found").font(.headline).foregroundStyle(.secondary)
                Text("Try a different search or pin on the map")
                    .font(.caption).foregroundStyle(.tertiary).multilineTextAlignment(.center)
            }
            .padding()
            Spacer()
        }
    }

    private var placesList: some View {
        List {
            if !viewModel.searchText.isEmpty {
                // Search results — no section header
                ForEach(viewModel.places) { place in
                    placeRow(place)
                }
            } else {
                Section {
                    ForEach(viewModel.places) { place in
                        placeRow(place)
                    }
                } header: {
                    Label("Nearby", systemImage: "location.fill")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .textCase(nil)
                }
            }
        }
        .listStyle(.plain)
    }

    private func placeRow(_ place: WRPlace) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(place.name).font(.headline)
            Text(place.address).font(.caption).foregroundStyle(.secondary).lineLimit(2)
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onTapGesture {
            onSelect(place)
            dismiss()
        }
    }
}

// MARK: - ViewModel

@MainActor
final class PlacePickerViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var places: [WRPlace] = []
    @Published var isLoading: Bool = false

    private let placesService: PlacesServiceProtocol
    private var searchTask: Task<Void, Never>?

    init(placesService: PlacesServiceProtocol) {
        self.placesService = placesService
    }

    func loadNearby() async {
        guard places.isEmpty && searchText.isEmpty else { return }
        isLoading = true
        places = (try? await placesService.fetchNearby()) ?? []
        isLoading = false
    }

    func onSearchTextChanged() async {
        searchTask?.cancel()

        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            await loadNearby()
            return
        }

        searchTask = Task {
            try? await Task.sleep(nanoseconds: 300_000_000)
            guard !Task.isCancelled else { return }
            await performSearch()
        }
    }

    func clearSearch() {
        places = []
        Task { await loadNearby() }
    }

    private func performSearch() async {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return }

        isLoading = true
        defer { isLoading = false }

        places = (try? await placesService.searchPlaces(query: query)) ?? []
    }
}

// MARK: - Preview

@MainActor
private struct PreviewPlacesService: PlacesServiceProtocol {
    func searchPlaces(query: String) async throws -> [WRPlace] {
        try? await Task.sleep(nanoseconds: 300_000_000)
        return [
            WRPlace(id: "1", name: "Apple Park", address: "1 Apple Park Way, Cupertino, CA", lat: 37.3349, lng: -122.0090),
            WRPlace(id: "2", name: "Apple Store", address: "300 Post St, San Francisco, CA", lat: 37.7886, lng: -122.4076)
        ]
    }
    func fetchNearby() async throws -> [WRPlace] {
        try? await Task.sleep(nanoseconds: 300_000_000)
        return [
            WRPlace(id: "3", name: "Local Café", address: "789 Oak Ave", lat: 37.7649, lng: -122.4294)
        ]
    }
    func getPlaceDetails(placeId: String) async throws -> WRPlace {
        WRPlace(id: placeId, name: "Sample", address: "123 Main St", lat: 0, lng: 0)
    }
}

#Preview {
    WRPlacePickerView(placesService: PreviewPlacesService()) { place in
        print("Selected: \(place.name)")
    }
}
