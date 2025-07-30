//
//  BundleContentManager.swift
//  ApplicationBundle
//
//  Created by Vika on 27.07.25.
//

import UIKit

final class BundleContentManager: ObservableObject {
    @Published var bundledImages: [BundledImage] = []
    @Published var appConfig: AppConfiguration?
    
    init() {
        loadBundledContent()
    }
    
    private func loadBundledContent() {
        loadConfiguration()
        loadBundledImages()
    }
    
    private func loadConfiguration() {
        guard let configURL = Bundle.main.url(forResource: "app_config", withExtension: "json") else {
            print("Configuration file not found in bundle")
            // Create default configuration
            appConfig = AppConfiguration(
                appName: "Default App",
                maxImagesDisplayed: 4,
                enableDarkMode: false,
                theme: "light",
                features: AppFeatures(enableCache: true, enableOfflineMode: true)
            )
            return
        }
        
        do {
            let data = try Data(contentsOf: configURL)
            appConfig = try JSONDecoder().decode(AppConfiguration.self, from: data)
        } catch {
            print("Error loading configuration: \(error)")
            // Create default configuration
            appConfig = AppConfiguration(
                appName: "Default App",
                maxImagesDisplayed: 4,
                enableDarkMode: false,
                theme: "light",
                features: AppFeatures(enableCache: true, enableOfflineMode: true)
            )
        }
    }
    
    private func loadBundledImages() {
        // Load images from bundle
        let imageNames = [
            "sample_nature_1",
            "sample_nature_2",
            "sample_city_1",
            "sample_city_2",
            "sample_abstract_1",
            "sample_abstract_2"
        ]
        
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
            }
        }
        
        // If no actual images found in bundle, create placeholder images
        if loadedImages.isEmpty {
            loadedImages = createPlaceholderImages()
        }
        
        bundledImages = loadedImages
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
        
        return placeholderData.map { (title, description, tags) in
            BundledImage(
                id: UUID(),
                image: createPlaceholderImage(title: title),
                title: title,
                description: description,
                tags: tags
            )
        }
    }
    
    private func createPlaceholderImage(title: String) -> UIImage {
        let size = CGSize(width: 300, height: 200)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            // Background gradient
            let colors = [UIColor.systemBlue.cgColor, UIColor.systemPurple.cgColor]
            let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors as CFArray, locations: nil)!
            
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
        let components = imageName.replacingOccurrences(of: "_", with: " ").capitalized
        return components
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
