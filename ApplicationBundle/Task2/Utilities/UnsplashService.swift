//
//  UnsplashService.swift
//  ApplicationBundle
//
//  Created by Vika on 27.07.25.
//

import Foundation

final class UnsplashService: ObservableObject {
    private let baseURL = "https://api.unsplash.com"
    private let session = URLSession.shared
    
    private let accessKey = "FZbJxjkXW6qY-DTis1tRU7MERYdRjj2qFvmFfEfnH-Q"
    
    // MARK: - Public Methods
    
    func getRandomPhoto(params: UnsplashSearchParams? = nil) async throws -> UnsplashPhoto {
        guard !accessKey.isEmpty else {
            throw UnsplashAPIError.noAccessKey
        }
        
        var urlComponents = URLComponents(string: "\(baseURL)/photos/random")!
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "client_id", value: accessKey)
        ]
        
        if let params = params {
            if let query = params.query {
                queryItems.append(URLQueryItem(name: "query", value: query))
            }
            if let orientation = params.orientation {
                queryItems.append(URLQueryItem(name: "orientation", value: orientation.rawValue))
            }
            if let category = params.category {
                queryItems.append(URLQueryItem(name: "topics", value: category.rawValue))
            }
            if let featured = params.featured {
                queryItems.append(URLQueryItem(name: "featured", value: String(featured)))
            }
            if let username = params.username {
                queryItems.append(URLQueryItem(name: "username", value: username))
            }
            if let count = params.count {
                queryItems.append(URLQueryItem(name: "count", value: String(count)))
            }
        }
        
        urlComponents.queryItems = queryItems
        
        guard let url = urlComponents.url else {
            throw UnsplashAPIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.setValue("Client-ID \(accessKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            let (data, response) = try await session.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                switch httpResponse.statusCode {
                case 401:
                    throw UnsplashAPIError.unauthorized
                case 403:
                    throw UnsplashAPIError.rateLimitExceeded
                case 200...299:
                    break
                default:
                    throw UnsplashAPIError.invalidResponse
                }
            }
            
            let decoder = JSONDecoder()
            let photo = try decoder.decode(UnsplashPhoto.self, from: data)
            return photo
            
        } catch let decodingError as DecodingError {
            throw UnsplashAPIError.decodingError(decodingError)
        } catch let networkError {
            throw UnsplashAPIError.networkError(networkError)
        }
    }
    
    func getRandomPhotos(count: Int = 10, params: UnsplashSearchParams? = nil) async throws -> [UnsplashPhoto] {
        guard !accessKey.isEmpty else {
            throw UnsplashAPIError.noAccessKey
        }
        
        var urlComponents = URLComponents(string: "\(baseURL)/photos/random")!
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "client_id", value: accessKey),
            URLQueryItem(name: "count", value: String(count))
        ]
        
        if let params = params {
            if let query = params.query {
                queryItems.append(URLQueryItem(name: "query", value: query))
            }
            if let orientation = params.orientation {
                queryItems.append(URLQueryItem(name: "orientation", value: orientation.rawValue))
            }
            if let category = params.category {
                queryItems.append(URLQueryItem(name: "topics", value: category.rawValue))
            }
            if let featured = params.featured {
                queryItems.append(URLQueryItem(name: "featured", value: String(featured)))
            }
            if let username = params.username {
                queryItems.append(URLQueryItem(name: "username", value: username))
            }
        }
        
        urlComponents.queryItems = queryItems
        
        guard let url = urlComponents.url else {
            throw UnsplashAPIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.setValue("Client-ID \(accessKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            let (data, response) = try await session.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                switch httpResponse.statusCode {
                case 401:
                    throw UnsplashAPIError.unauthorized
                case 403:
                    throw UnsplashAPIError.rateLimitExceeded
                case 200...299:
                    break
                default:
                    throw UnsplashAPIError.invalidResponse
                }
            }
            
            let decoder = JSONDecoder()
            let photos = try decoder.decode([UnsplashPhoto].self, from: data)
            return photos
            
        } catch let decodingError as DecodingError {
            throw UnsplashAPIError.decodingError(decodingError)
        } catch let networkError {
            throw UnsplashAPIError.networkError(networkError)
        }
    }
    
    func getPhotos(page: Int = 1, perPage: Int = 10, orderBy: String = "popular") async throws -> [UnsplashPhoto] {
        guard !accessKey.isEmpty else {
            throw UnsplashAPIError.noAccessKey
        }
        
        var urlComponents = URLComponents(string: "\(baseURL)/photos")!
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: accessKey),
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "per_page", value: String(perPage)),
            URLQueryItem(name: "order_by", value: orderBy)
        ]
        
        guard let url = urlComponents.url else {
            throw UnsplashAPIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.setValue("Client-ID \(accessKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            let (data, response) = try await session.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                switch httpResponse.statusCode {
                case 401:
                    throw UnsplashAPIError.unauthorized
                case 403:
                    throw UnsplashAPIError.rateLimitExceeded
                case 200...299:
                    break
                default:
                    throw UnsplashAPIError.invalidResponse
                }
            }
            
            let decoder = JSONDecoder()
            let photos = try decoder.decode([UnsplashPhoto].self, from: data)
            return photos
            
        } catch let decodingError as DecodingError {
            throw UnsplashAPIError.decodingError(decodingError)
        } catch let networkError {
            throw UnsplashAPIError.networkError(networkError)
        }
    }
}
