//
//  ImageCardView.swift
//  ApplicationBundle
//
//  Created by Vika on 30.07.25.
//

import SwiftUI

struct ImageCardView: View {
    let bundledImage: BundledImage
    let config: AppConfiguration?
    let onTap: () -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            Image(uiImage: bundledImage.image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 150, height: 120)
                .clipped()
                .cornerRadius(config?.effectiveImageCornerRadius ?? 12)
                .shadow(radius: 3)
                .scaleEffect(config?.effectiveEnableImageAnimations == true ? 1.0 : 1.0)
                .animation(
                    config?.effectiveEnableImageAnimations == true ? 
                    .easeInOut(duration: 0.2) : .none, 
                    value: config?.effectiveEnableImageAnimations
                )
                .onTapGesture {
                    onTap()
                }
            
            VStack(spacing: 4) {
                Text(bundledImage.title)
                    .font(.caption)
                    .bold()
                    .lineLimit(1)
                
                if config?.effectiveShowImageDescriptions == true {
                    Text(bundledImage.description)
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                }
                
                if config?.effectiveShowImageTags == true && !bundledImage.tags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 4) {
                            ForEach(bundledImage.tags.prefix(3), id: \.self) { tag in
                                Text(tag)
                                    .font(.caption2)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background((config?.themeColor.opacity(0.2) ?? Color.blue.opacity(0.2)))
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
            }
            .frame(width: 150)
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: config?.effectiveImageCornerRadius ?? 12)
                .fill(Color.gray.opacity(0.1))
        )
    }
}
