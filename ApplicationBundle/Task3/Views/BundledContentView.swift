//
//  BundledContentView.swift
//  ApplicationBundle
//
//  Created by Vika on 27.07.25.
//

import SwiftUI

struct BundledContentView: View {
    @StateObject private var bundleManager = BundleContentManager()
    @State private var selectedImage: BundledImage?
    @State private var showingConfigDetails = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                configurationInfoSection
                
                if bundleManager.appConfig?.features.effectiveEnableImageSearch == true {
                    searchSection
                }
                
                bundledImagesSection

                Spacer()
            }
            .padding()
            .navigationTitle(bundleManager.appConfig?.appName ?? "Bundle Content")
            .preferredColorScheme(bundleManager.appConfig?.colorScheme)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: {
                            bundleManager.reloadConfiguration()
                        }) {
                            Label("Reload Configuration", systemImage: "arrow.clockwise")
                        }
                        
                        Button(action: {
                            bundleManager.resetToDefaultConfiguration()
                        }) {
                            Label("Reset to Default", systemImage: "arrow.uturn.backward")
                        }
                        
                        Button(action: {
                            showingConfigDetails = true
                        }) {
                            Label("Show Config Details", systemImage: "info.circle")
                        }
                    } label: {
                        Image(systemName: bundleManager.isReloading ? "arrow.clockwise" : "ellipsis.circle")
                            .rotationEffect(.degrees(bundleManager.isReloading ? 360 : 0))
                            .animation(bundleManager.isReloading ?
                                     .linear(duration: 1).repeatForever(autoreverses: false) :
                                     .default, value: bundleManager.isReloading)
                    }
                    .disabled(bundleManager.isReloading)
                }
            }
            .sheet(item: $selectedImage) { image in
                ImageDetailModalView(bundledImage: image)
                    .preferredColorScheme(bundleManager.appConfig?.colorScheme)
            }
            .sheet(isPresented: $showingConfigDetails) {
                ConfigurationDetailSheet(
                    config: bundleManager.appConfig,
                    source: bundleManager.configurationSource,
                    lastReload: bundleManager.lastReloadTime
                )
            }
        }
    }
    
    // MARK: - Configuration Info Section
    private var configurationInfoSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("App Configuration")
                    .font(.headline)
                
                Spacer()
                
                Text(bundleManager.configurationSource)
                    .font(.caption2)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(bundleManager.appConfig?.themeColor.opacity(0.2) ?? Color.blue.opacity(0.2))
                    .cornerRadius(8)
            }
            
            if let config = bundleManager.appConfig {
                VStack(alignment: .leading, spacing: 8) {
                    configRow("App Name:", config.appName)
                    configRow("Max Images:", "\(config.maxImagesDisplayed)")
                    configRow("Grid Columns:", "\(config.effectiveGridColumns)")
                    configRow("Corner Radius:", "\(Int(config.effectiveImageCornerRadius))px")
                    configRow("Dark Mode:", config.enableDarkMode ? "Enabled" : "Disabled")
                    configRow("Theme:", config.theme.capitalized)
                    
                    HStack {
                        Text("Features:")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        Spacer()
                        
                        HStack(spacing: 4) {
                            if config.features.effectiveEnableImageSearch {
                                featureBadge("Search", color: .green)
                            }
                            if config.features.effectiveEnableImageSharing {
                                featureBadge("Share", color: .blue)
                            }
                            if config.effectiveShowImageTags {
                                featureBadge("Tags", color: .purple)
                            }
                        }
                    }
                }
            } else {
                Text("Failed to load configuration")
                    .foregroundColor(.red)
            }
        }
        .padding()
        .background((bundleManager.appConfig?.themeColor.opacity(0.1) ?? Color.blue.opacity(0.1)))
        .cornerRadius(10)
        .overlay(
            bundleManager.isReloading ?
            ProgressView()
                .scaleEffect(0.8)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                .padding()
            : nil
        )
    }
    
    // MARK: - Search Section
    private var searchSection: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search images...", text: $bundleManager.searchText)
                .textFieldStyle(PlainTextFieldStyle())
                .onChange(of: bundleManager.searchText) { newValue in
                    bundleManager.searchImages(query: newValue)
                }
            
            if !bundleManager.searchText.isEmpty {
                Button("Clear") {
                    bundleManager.searchImages(query: "")
                }
                .font(.caption)
                .foregroundColor(bundleManager.appConfig?.themeColor ?? .blue)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemGray6))
        )
    }
    
    // MARK: - Bundled Images Section
    private var bundledImagesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Bundled Images")
                    .font(.headline)
                
                Spacer()
                
                Text("Showing \(bundleManager.filteredImages.count) of \(bundleManager.bundledImages.count)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            if bundleManager.filteredImages.isEmpty {
                emptyStateView
            } else {
                imageGridView
            }
        }
    }
    
    // MARK: - Image Grid
    private var imageGridView: some View {
        ScrollView {
            LazyVGrid(
                columns: Array(
                    repeating: GridItem(.flexible()),
                    count: bundleManager.appConfig?.effectiveGridColumns ?? 2
                ),
                spacing: 15
            ) {
                ForEach(bundleManager.filteredImages) { bundledImage in
                    ImageCardView(
                        bundledImage: bundledImage,
                        config: bundleManager.appConfig
                    ) {
                        selectedImage = bundledImage
                    }
                }
            }
        }
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: bundleManager.searchText.isEmpty ? "photo.stack" : "magnifyingglass")
                .font(.system(size: 40))
                .foregroundColor(.gray)
            
            Text(bundleManager.searchText.isEmpty ? "No images found" : "No search results")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(bundleManager.searchText.isEmpty ?
                 "Check your bundle configuration" :
                 "Try a different search term")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 30)
    }
    
    // MARK: - Helper Views
    private func configRow(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .font(.caption)
                .bold()
        }
    }
    
    private func featureBadge(_ title: String, color: Color) -> some View {
        Text(title)
            .font(.caption2)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(color.opacity(0.2))
            .foregroundColor(color)
            .cornerRadius(6)
    }
}

struct BundledContentView_Previews: PreviewProvider {
    static var previews: some View {
        BundledContentView()
    }
}
