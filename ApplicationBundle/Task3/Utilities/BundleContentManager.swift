//
//  BundleContentManager.swift
//  ApplicationBundle
//
//  Created by Vika on 27.07.25.
//

import UIKit
import SwiftUI

final class BundleContentManager: ObservableObject {
    @Published var bundledImages: [BundledImage] = []
    @Published var appConfig: AppConfiguration?
    @Published var isReloading: Bool = false
    @Published var lastReloadTime: Date = Date()
    @Published var configurationSource: String = "JSON"
    @Published var searchText: String = ""
    @Published var filteredImages: [BundledImage] = []
    
    private let imageNames = [
        "sample_nature_1",
        "sample_nature_2",
        "sample_city_1",
        "sample_city_2",
        "sample_abstract_1",
        "sample_abstract_2"
    ]
    
    init() {
        loadBundledContent()
    }
    
    // MARK: - Public Methods
    
    func reloadConfiguration() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isReloading = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.loadConfiguration()
            self.applyConfigurationToImages()
            self.lastReloadTime = Date()
            
            withAnimation(.easeInOut(duration: 0.3)) {
                self.isReloading = false
            }
        }
    }
    
    func resetToDefaultConfiguration() {
        withAnimation(.easeInOut(duration: 0.3)) {
            self.appConfig = .defaultConfig
            self.configurationSource = "Default"
            self.applyConfigurationToImages()
            self.lastReloadTime = Date()
        }
    }
    
    func searchImages(query: String) {
        searchText = query
        applyConfigurationToImages()
    }
    
    // MARK: - Private Methods
    
    private func loadBundledContent() {
        loadConfiguration()
        loadBundledImages()
        applyConfigurationToImages()
    }
    
    private func loadConfiguration() {
        guard let configURL = Bundle.main.url(forResource: "app_config", withExtension: "json") else {
            print("❌ Configuration file not found in bundle")
            appConfig = .defaultConfig
            configurationSource = "Default (JSON not found)"
            return
        }
        
        do {
            let data = try Data(contentsOf: configURL)
            appConfig = try JSONDecoder().decode(AppConfiguration.self, from: data)
            configurationSource = "JSON"
            print("✅ Configuration loaded from JSON successfully")
        } catch {
            print("❌ Error loading configuration: \(error)")
            appConfig = .defaultConfig
            configurationSource = "Default (JSON error)"
        }
    }
    
    private func loadBundledImages() {
        var loadedImages: [BundledImage] = []
        
        for imageName in imageNames {
            if let image = UIImage(named: imageName) {
                let bundledImage = BundledImage(
                    id: UUID(),
                    image: image,
                    title: generateTitle(from: imageName),
                    description: generateDescription(from: imageName),
                    tags: generateTags(from: imageName)
                )
                loadedImages.append(bundledImage)
                print("✅ Loaded image: \(imageName)")
            } else {
                print("⚠️ Image not found: \(imageName)")
            }
        }
        
        // If no actual images found in bundle, create placeholder images
        if loadedImages.isEmpty {
            print("⚠️ No bundle images found, creating placeholders")
            loadedImages = createPlaceholderImages()
        }
        
        bundledImages = loadedImages
    }
    
    private func applyConfigurationToImages() {
        guard let config = appConfig else {
            filteredImages = bundledImages
            return
        }
        
        var images = bundledImages
        
        // Apply search filter if search is enabled
        if config.features.effectiveEnableImageSearch && !searchText.isEmpty {
            images = images.filter { image in
                image.title.localizedCaseInsensitiveContains(searchText) ||
                image.description.localizedCaseInsensitiveContains(searchText) ||
                image.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
        
        // Apply max images limit
        let maxImages = config.maxImagesDisplayed
        filteredImages = Array(images.prefix(maxImages))
        
        print("📊 Applied configuration: showing \(filteredImages.count) of \(bundledImages.count) images")
    }
    
    private func createPlaceholderImages() -> [BundledImage] {
        let placeholderData = [
            ("Nature Landscape", "Beautiful mountain landscape with clear blue sky", ["nature", "mountain", "landscape"]),
            ("City Skyline", "Modern city skyline during golden hour", ["city", "urban", "skyline"]),
            ("Abstract Art", "Colorful abstract geometric patterns", ["abstract", "art", "geometric"]),
            ("Ocean View", "Peaceful ocean waves at sunset", ["ocean", "sunset", "peaceful"]),
            ("Forest Path", "Mysterious forest path in autumn", ["forest", "autumn", "path"]),
            ("Desert Dunes", "Golden sand dunes under starry sky", ["desert", "dunes", "stars"])
        ]
        
        return placeholderData.enumerated().map { index, data in
            let (title, description, tags) = data
            return BundledImage(
                id: UUID(),
                image: createPlaceholderImage(title: title, index: index),
                title: title,
                description: description,
                tags: tags
            )
        }
    }
    
    private func createPlaceholderImage(title: String, index: Int) -> UIImage {
        let size = CGSize(width: 300, height: 200)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            // Different gradients for variety
            let colorPairs = [
                (UIColor.systemBlue, UIColor.systemPurple),
                (UIColor.systemGreen, UIColor.systemTeal),
                (UIColor.systemOrange, UIColor.systemRed),
                (UIColor.systemPink, UIColor.systemIndigo),
                (UIColor.systemYellow, UIColor.systemOrange),
                (UIColor.systemTeal, UIColor.systemBlue)
            ]
            
            let colorPair = colorPairs[index % colorPairs.count]
            let colors = [colorPair.0.cgColor, colorPair.1.cgColor]
            
            guard let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                          colors: colors as CFArray,
                                          locations: nil) else { return }
            
            context.cgContext.drawLinearGradient(
                gradient,
                start: CGPoint.zero,
                end: CGPoint(x: size.width, y: size.height),
                options: []
            )
            
            // Add title text
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 24, weight: .bold),
                .foregroundColor: UIColor.white
            ]
            
            let text = title
            let textSize = text.size(withAttributes: attributes)
            let textRect = CGRect(
                x: (size.width - textSize.width) / 2,
                y: (size.height - textSize.height) / 2,
                width: textSize.width,
                height: textSize.height
            )
            
            text.draw(in: textRect, withAttributes: attributes)
        }
    }
    
    private func generateTitle(from imageName: String) -> String {
        return imageName
            .replacingOccurrences(of: "_", with: " ")
            .split(separator: " ")
            .map { $0.capitalized }
            .joined(separator: " ")
    }
    
    private func generateDescription(from imageName: String) -> String {
        if imageName.contains("nature") {
            return "Beautiful natural landscape captured in stunning detail"
        } else if imageName.contains("city") {
            return "Urban architecture and city life in modern setting"
        } else if imageName.contains("abstract") {
            return "Creative abstract composition with vibrant colors"
        } else {
            return "High quality image from our curated collection"
        }
    }
    
    private func generateTags(from imageName: String) -> [String] {
        var tags: [String] = []
        
        if imageName.contains("nature") {
            tags.append(contentsOf: ["nature", "outdoor", "landscape"])
        }
        if imageName.contains("city") {
            tags.append(contentsOf: ["urban", "architecture", "modern"])
        }
        if imageName.contains("abstract") {
            tags.append(contentsOf: ["art", "creative", "colorful"])
        }
        
        return tags
    }
}
