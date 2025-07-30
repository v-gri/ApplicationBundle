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
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Configuration Info
                VStack(alignment: .leading, spacing: 10) {
                    Text("App Configuration")
                        .font(.headline)
                    
                    if let config = bundleManager.appConfig {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("App Name:")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Spacer()
                                Text(config.appName)
                                    .font(.caption)
                                    .bold()
                            }
                            
                            HStack {
                                Text("Max Images:")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Spacer()
                                Text("\(config.maxImagesDisplayed)")
                                    .font(.caption)
                                    .bold()
                            }
                            
                            HStack {
                                Text("Dark Mode:")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Spacer()
                                Text(config.enableDarkMode ? "Enabled" : "Disabled")
                                    .font(.caption)
                                    .bold()
                            }
                            
                            HStack {
                                Text("Theme:")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Spacer()
                                Text(config.theme)
                                    .font(.caption)
                                    .bold()
                            }
                        }
                    } else {
                        Text("Failed to load configuration")
                            .foregroundColor(.red)
                    }
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(10)
                
                // Bundled Images Section
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Bundled Images")
                            .font(.headline)
                        
                        Spacer()
                        
                        Text("Showing \(min(bundleManager.bundledImages.count, bundleManager.appConfig?.maxImagesDisplayed ?? 0)) of \(bundleManager.bundledImages.count)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    if bundleManager.bundledImages.isEmpty {
                        Text("No bundled images found")
                            .foregroundColor(.gray)
                            .italic()
                    } else {
                        ScrollView {
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 15) {
                                ForEach(Array(bundleManager.bundledImages.prefix(bundleManager.appConfig?.maxImagesDisplayed ?? bundleManager.bundledImages.count).enumerated()), id: \.offset) { index, bundledImage in
                                    VStack(spacing: 8) {
                                        Image(uiImage: bundledImage.image)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 150, height: 120)
                                            .clipped()
                                            .cornerRadius(12)
                                            .shadow(radius: 3)
                                            .onTapGesture {
                                                selectedImage = bundledImage
                                            }
                                        
                                        VStack(spacing: 4) {
                                            Text(bundledImage.title)
                                                .font(.caption)
                                                .bold()
                                                .lineLimit(1)
                                            
                                            Text(bundledImage.description)
                                                .font(.caption2)
                                                .foregroundColor(.gray)
                                                .lineLimit(2)
                                                .multilineTextAlignment(.center)
                                        }
                                        .frame(width: 150)
                                    }
                                    .padding(8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.gray.opacity(0.1))
                                    )
                                }
                            }
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Bundle Content")
            .preferredColorScheme(bundleManager.appConfig?.enableDarkMode == true ? .dark : .light)
            .sheet(item: $selectedImage) { image in
                ImageDetailModalView(bundledImage: image)
            }
        }
    }
}

struct BundledContentView_Previews: PreviewProvider {
    static var previews: some View {
        BundledContentView()
    }
}
