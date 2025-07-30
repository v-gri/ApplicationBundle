//
//  ImageCacheError.swift
//  ApplicationBundle
//
//  Created by Vika on 27.07.25.
//

import Foundation

enum ImageCacheError: Error, LocalizedError {
    case invalidURL
    case noData
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL provided"
        case .noData:
            return "No data received from server"
        }
    }
}
