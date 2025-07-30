//
//  UnsplashPhotoDetailView.swift
//  ApplicationBundle
//
//  Created by Vika on 27.07.25.
//

import SwiftUI

struct UnsplashPhotoDetailView: View {
    let photo: UnsplashPhoto
    let cacheManager: ImageCacheManager
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Image
                    if let cachedInfo = cacheManager.getCachedPhotoInfo(for: photo.id) {
                        AsyncImage(url: cachedInfo.localURL) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .cornerRadius(12)
                        } placeholder: {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 300)
                                .overlay(ProgressView())
                        }
                    }
                    
                    // Photo information
                    VStack(alignment: .leading, spacing: 12) {
                        if let description = photo.description ?? photo.altDescription {
                            Text(description)
                                .font(.headline)
                                .foregroundColor(.primary)
                        }
                        
                        // User info
                        HStack {
                            AsyncImage(url: URL(string: photo.user.profileImage?.medium ?? "")) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 40, height: 40)
                                    .clipShape(Circle())
                            } placeholder: {
                                Circle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Image(systemName: "person.fill")
                                            .foregroundColor(.white)
                                    )
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(photo.user.name)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                Text("@\(photo.user.username)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                        
                        // Stats
                        HStack {
                            Label("\(photo.likes)", systemImage: "heart")
                            Spacer()
                            Text("\(photo.width) × \(photo.height)")
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                        
                        if let cachedInfo = cacheManager.getCachedPhotoInfo(for: photo.id) {
                            Divider()
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Cache Information")
                                    .font(.headline)
                                
                                HStack {
                                    Text("File Size:")
                                    Spacer()
                                    Text(ByteCountFormatter.string(fromByteCount: cachedInfo.size, countStyle: .file))
                                }
                                
                                HStack {
                                    Text("Cached:")
                                    Spacer()
                                    Text(DateFormatter.localizedString(from: cachedInfo.cachedDate, dateStyle: .medium, timeStyle: .short))
                                }
                            }
                            .font(.caption)
                            .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Photo Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Remove from Cache", role: .destructive) {
                        cacheManager.removePhoto(photoId: photo.id)
                        dismiss()
                    }
                }
            }
        }
    }
}
