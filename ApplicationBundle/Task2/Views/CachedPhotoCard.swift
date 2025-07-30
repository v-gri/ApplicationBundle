//
//  CachedPhotoCard.swift
//  ApplicationBundle
//
//  Created by Vika on 27.07.25.
//

import SwiftUI

struct CachedPhotoCard: View {
    let cachedInfo: ImageCacheManager.CachedPhotoInfo
    let onTap: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            // Image
            AsyncImage(url: cachedInfo.localURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame( width: 170, height: 120)
                    .clipped()
                    .cornerRadius(8)
            } placeholder: {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 120)
                    .overlay(
                        ProgressView()
                    )
            }
            .overlay(
                // Delete button
                Button(action: onDelete) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.blue)
                        .background(Color.white)
                        .clipShape(Circle())
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                .padding(8)
            )
            
            // Photo info
            VStack(alignment: .leading, spacing: 4) {
                if let description = cachedInfo.photo.description ?? cachedInfo.photo.altDescription {
                    Text(description)
                        .font(.caption)
                        .lineLimit(1)
                        .foregroundColor(.primary)
                } else {
                    Text("Photo by \(cachedInfo.photo.user.name)")
                        .font(.caption)
                        .lineLimit(1)
                        .foregroundColor(.primary)
                }
                
                HStack {
                    Text(formatFileSize(cachedInfo.size))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(formatDate(cachedInfo.cachedDate))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }
    
    private func formatFileSize(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}
