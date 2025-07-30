//
//  AppConfiguration.swift
//  ApplicationBundle
//
//  Created by Vika on 27.07.25.
//

import Foundation

struct AppConfiguration: Codable {
    let appName: String
    let maxImagesDisplayed: Int
    let enableDarkMode: Bool
    let theme: String
    let features: AppFeatures
}
