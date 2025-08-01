//
//  AppConfiguration.swift
//  ApplicationBundle
//
//  Created by Vika on 27.07.25.
//

import SwiftUI

struct AppConfiguration: Codable {
    let appName: String
    let maxImagesDisplayed: Int
    let enableDarkMode: Bool
    let theme: String
    let gridColumns: Int?
    let imageCornerRadius: Double?
    let showImageTags: Bool?
    let showImageDescriptions: Bool?
    let enableImageAnimations: Bool?
    let imageNames: [String]?
    let features: AppFeatures
    
    var effectiveImageNames: [String] {
        return imageNames ?? [
            "sample_nature_1",
            "sample_nature_2",
            "sample_city_1",
            "sample_city_2",
            "sample_abstract_1",
            "sample_abstract_2"
        ]
    }
    
    var effectiveGridColumns: Int {
        return gridColumns ?? 2
    }
    
    var effectiveImageCornerRadius: Double {
        return imageCornerRadius ?? 12.0
    }
    
    var effectiveShowImageTags: Bool {
        return showImageTags ?? true
    }
    
    var effectiveShowImageDescriptions: Bool {
        return showImageDescriptions ?? true
    }
    
    var effectiveEnableImageAnimations: Bool {
        return enableImageAnimations ?? true
    }
    
    var themeColor: Color {
        switch theme.lowercased() {
        case "modern":
            return .blue
        case "nature":
            return .green
        case "urban":
            return .gray
        case "creative":
            return .purple
        case "warm":
            return .orange
        default:
            return .blue
        }
    }
    
    var colorScheme: ColorScheme? {
        return enableDarkMode ? .dark : .light
    }
    
    static let defaultConfig = AppConfiguration(
        appName: "Default App",
        maxImagesDisplayed: 4,
        enableDarkMode: false,
        theme: "modern",
        gridColumns: 2,
        imageCornerRadius: 12,
        showImageTags: true,
        showImageDescriptions: true,
        enableImageAnimations: true,
        imageNames: [
            "sample_nature_1",
            "sample_nature_2",
            "sample_city_1",
            "sample_city_2",
            "sample_abstract_1",
            "sample_abstract_2"
        ],
        features: AppFeatures(enableCache: true, enableOfflineMode: true)
    )
}
