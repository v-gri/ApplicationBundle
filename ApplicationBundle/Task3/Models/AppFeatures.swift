//
//  AppFeatures.swift
//  ApplicationBundle
//
//  Created by Vika on 27.07.25.
//

import Foundation

struct AppFeatures: Codable {
    let enableCache: Bool
    let enableOfflineMode: Bool
    let enableImageSearch: Bool?
    let enableImageSharing: Bool?
    
    var effectiveEnableImageSearch: Bool {
        return enableImageSearch ?? false
    }
    
    var effectiveEnableImageSharing: Bool {
        return enableImageSharing ?? false
    }
    
    init(enableCache: Bool = true,
         enableOfflineMode: Bool = true,
         enableImageSearch: Bool? = nil,
         enableImageSharing: Bool? = nil) {
        self.enableCache = enableCache
        self.enableOfflineMode = enableOfflineMode
        self.enableImageSearch = enableImageSearch
        self.enableImageSharing = enableImageSharing
    }
}
