//
//  UnsplashModels.swift
//  ApplicationBundle
//
//  Created by Vika on 27.07.25.
//

import Foundation

// MARK: - Unsplash Photo Model
struct UnsplashPhoto: Codable, Identifiable {
    let id: String
    let createdAt: String
    let updatedAt: String
    let width: Int
    let height: Int
    let color: String
    let blurHash: String?
    let likes: Int
    let likedByUser: Bool
    let description: String?
    let altDescription: String?
    let user: UnsplashUser
    let urls: UnsplashURLs
    let links: UnsplashLinks?
    
    enum CodingKeys: String, CodingKey {
        case id, width, height, color, likes, description, user, urls, links
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case blurHash = "blur_hash"
        case likedByUser = "liked_by_user"
        case altDescription = "alt_description"
    }
}

// MARK: - Unsplash User Model
struct UnsplashUser: Codable {
    let id: String
    let username: String
    let name: String
    let firstName: String?
    let lastName: String?
    let portfolioURL: String?
    let bio: String?
    let location: String?
    let totalLikes: Int?
    let totalPhotos: Int?
    let totalCollections: Int?
    let profileImage: UnsplashProfileImage?
    let links: UnsplashUserLinks?
    
    enum CodingKeys: String, CodingKey {
        case id, username, name, bio, location, links
        case firstName = "first_name"
        case lastName = "last_name"
        case portfolioURL = "portfolio_url"
        case totalLikes = "total_likes"
        case totalPhotos = "total_photos"
        case totalCollections = "total_collections"
        case profileImage = "profile_image"
    }
}

// MARK: - Unsplash URLs Model
struct UnsplashURLs: Codable {
    let raw: String
    let full: String
    let regular: String
    let small: String
    let thumb: String
}

// MARK: - Unsplash Links Model
struct UnsplashLinks: Codable {
    let selfLink: String
    let html: String
    let download: String
    let downloadLocation: String
    
    enum CodingKeys: String, CodingKey {
        case html, download
        case selfLink = "self"
        case downloadLocation = "download_location"
    }
}

// MARK: - Unsplash Profile Image Model
struct UnsplashProfileImage: Codable {
    let small: String
    let medium: String
    let large: String
}

// MARK: - Unsplash User Links Model
struct UnsplashUserLinks: Codable {
    let selfLink: String
    let html: String
    let photos: String
    let likes: String
    let portfolio: String
    
    enum CodingKeys: String, CodingKey {
        case html, photos, likes, portfolio
        case selfLink = "self"
    }
}

// MARK: - API Error Model
enum UnsplashAPIError: Error, LocalizedError {
    case invalidURL
    case noAccessKey
    case networkError(Error)
    case decodingError(Error)
    case noData
    case invalidResponse
    case rateLimitExceeded
    case unauthorized
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noAccessKey:
            return "No access key provided"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .noData:
            return "No data received"
        case .invalidResponse:
            return "Invalid response from server"
        case .rateLimitExceeded:
            return "Rate limit exceeded. Please try again later."
        case .unauthorized:
            return "Unauthorized. Please check your access key."
        }
    }
}

// MARK: - Search Parameters
struct UnsplashSearchParams {
    let query: String?
    let orientation: UnsplashOrientation?
    let category: UnsplashCategory?
    let featured: Bool?
    let username: String?
    let count: Int?
    
    init(query: String? = nil,
         orientation: UnsplashOrientation? = nil,
         category: UnsplashCategory? = nil,
         featured: Bool? = nil,
         username: String? = nil,
         count: Int? = nil) {
        self.query = query
        self.orientation = orientation
        self.category = category
        self.featured = featured
        self.username = username
        self.count = count
    }
}

enum UnsplashOrientation: String, CaseIterable {
    case landscape
    case portrait
    case squarish
    
    var displayName: String {
        switch self {
        case .landscape: return "Landscape"
        case .portrait: return "Portrait"
        case .squarish: return "Square"
        }
    }
}

enum UnsplashCategory: String, CaseIterable {
    case nature
    case people
    case technology
    case animals
    case food
    case travel
    case architecture
    case business
    case fashion
    case film
    case health
    case interiors
    case street
    case experimental
    case textures
    case current_events = "current-events"
    
    var displayName: String {
        switch self {
        case .nature: return "Nature"
        case .people: return "People"
        case .technology: return "Technology"
        case .animals: return "Animals"
        case .food: return "Food"
        case .travel: return "Travel"
        case .architecture: return "Architecture"
        case .business: return "Business"
        case .fashion: return "Fashion"
        case .film: return "Film"
        case .health: return "Health"
        case .interiors: return "Interiors"
        case .street: return "Street"
        case .experimental: return "Experimental"
        case .textures: return "Textures"
        case .current_events: return "Current Events"
        }
    }
}
