//
//  ConfigurationDetailSheet.swift
//  ApplicationBundle
//
//  Created by Vika on 30.07.25.
//

import SwiftUI

struct ConfigurationDetailSheet: View {
    let config: AppConfiguration?
    let source: String
    let lastReload: Date
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section("Configuration Source") {
                    HStack {
                        Text("Source")
                        Spacer()
                        Text(source)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Last Reload")
                        Spacer()
                        Text(DateFormatter.localizedString(from: lastReload, dateStyle: .none, timeStyle: .medium))
                            .foregroundColor(.secondary)
                    }
                }
                
                if let config = config {
                    Section("Display Settings") {
                        detailRow("Max Images", "\(config.maxImagesDisplayed)")
                        detailRow("Grid Columns", "\(config.effectiveGridColumns)")
                        detailRow("Corner Radius", "\(Int(config.effectiveImageCornerRadius))px")
                        detailRow("Show Tags", config.effectiveShowImageTags ? "Yes" : "No")
                        detailRow("Show Descriptions", config.effectiveShowImageDescriptions ? "Yes" : "No")
                        detailRow("Animations", config.effectiveEnableImageAnimations ? "Enabled" : "Disabled")
                    }
                    
                    Section("App Settings") {
                        detailRow("App Name", config.appName)
                        detailRow("Theme", config.theme.capitalized)
                        detailRow("Dark Mode", config.enableDarkMode ? "Enabled" : "Disabled")
                    }
                    
                    Section("Features") {
                        detailRow("Cache", config.features.enableCache ? "Enabled" : "Disabled")
                        detailRow("Offline Mode", config.features.enableOfflineMode ? "Enabled" : "Disabled")
                        detailRow("Image Search", config.features.effectiveEnableImageSearch ? "Enabled" : "Disabled")
                        detailRow("Image Sharing", config.features.effectiveEnableImageSharing ? "Enabled" : "Disabled")
                    }
                }
            }
            .navigationTitle("Configuration Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func detailRow(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
        }
    }
}
