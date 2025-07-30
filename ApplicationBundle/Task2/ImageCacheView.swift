//
//  ImageCacheView.swift
//  ApplicationBundle
//
//  Created by Vika on 27.07.25.
//

import SwiftUI

struct ImageCacheView: View {
    @StateObject private var viewModel = ImageCacheViewModel()
    @State private var showFilters = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                headerSection
                Divider()
                ScrollView {
                    VStack(spacing: 20) {
                        downloadControlsSection
                        if !viewModel.cachedPhotos.isEmpty {
                            cachedImagesSection
                        } else {
                            emptyStateSection
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Unsplash Cache")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("Clear Old Cache (7+ days)") {
                            viewModel.clearOldCache()
                        }
                        Button("Clear All Cache", role: .destructive) {
                            viewModel.clearAllCache()
                        }
                        Button("Toggle Filters") {
                            showFilters.toggle()
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .alert("Message", isPresented: $viewModel.showAlert) {
                Button("OK") { }
            } message: {
                Text(viewModel.alertMessage)
            }
            .sheet(item: $viewModel.selectedPhoto) { photo in
                UnsplashPhotoDetailView(photo: photo, cacheManager: viewModel.cacheManager)
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Cached Images")
                        .font(.headline)
                    Text("\(viewModel.cachedImagesCount) photos")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Cache Size")
                        .font(.headline)
                    Text(viewModel.cacheSize)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            if viewModel.isLoading {
                ProgressView("Loading images...")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
    }
    
    private var downloadControlsSection: some View {
        VStack(spacing: 16) {
            VStack(spacing: 12) {
                TextField("Search photos (optional)", text: Binding(
                    get: { viewModel.searchQuery },
                    set: { viewModel.setSearchQuery($0) }
                ))
                .textFieldStyle(RoundedBorderTextFieldStyle())
                if showFilters {
                    filtersSection
                }
            }
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    Button("Random Photo") {
                        Task {
                            await viewModel.downloadRandomPhoto()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(viewModel.isLoading)
                    Button("5 Random Photos") {
                        Task {
                            await viewModel.downloadMultiplePhotos()
                        }
                    }
                    .buttonStyle(.bordered)
                    .disabled(viewModel.isLoading)
                }
                Button("Popular Photos") {
                    Task {
                        await viewModel.downloadPopularPhotos()
                    }
                }
                .buttonStyle(.bordered)
                .disabled(viewModel.isLoading)
                .frame(maxWidth: .infinity)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
    
    private var filtersSection: some View {
        VStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Orientation")
                    .font(.subheadline)
                    .fontWeight(.medium)
                Picker("Orientation", selection: Binding(
                    get: { viewModel.selectedOrientation },
                    set: { viewModel.setOrientation($0) }
                )) {
                    Text("Any").tag(UnsplashOrientation?.none)
                    ForEach(UnsplashOrientation.allCases, id: \.self) { orientation in
                        Text(orientation.displayName).tag(orientation as UnsplashOrientation?)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            VStack(alignment: .leading, spacing: 8) {
                Text("Category")
                    .font(.subheadline)
                    .fontWeight(.medium)
                Picker("Category", selection: Binding(
                    get: { viewModel.selectedCategory },
                    set: { viewModel.setCategory($0) }
                )) {
                    Text("Any").tag(UnsplashCategory?.none)
                    ForEach(UnsplashCategory.allCases, id: \.self) { category in
                        Text(category.displayName).tag(category as UnsplashCategory?)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemGray5))
        )
    }
    
    private var cachedImagesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Cached Images (\(viewModel.cachedImagesCount))")
                .font(.headline)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 2), spacing: 8) {
                ForEach(Array(viewModel.cachedPhotos.keys), id: \.self) { photoId in
                    if let cachedInfo = viewModel.cacheManager.getCachedPhotoInfo(for: photoId) {
                        CachedPhotoCard(
                            cachedInfo: cachedInfo,
                            onTap: { viewModel.selectedPhoto = cachedInfo.photo },
                            onDelete: { viewModel.removePhoto(photoId: photoId) }
                        )
                    }
                }
            }
        }
    }
    
    private var emptyStateSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "photo.stack")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            Text("No Cached Images")
                .font(.headline)
            Text("Download some images from Unsplash to get started")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 40)
    }
}

struct ImageCacheView_Previews: PreviewProvider {
    static var previews: some View {
        ImageCacheView()
    }
}
