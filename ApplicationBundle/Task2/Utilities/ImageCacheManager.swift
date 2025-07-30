//
//  ImageCacheManager.swift
//  ApplicationBundle
//
//  Created by Vika on 27.07.25.
//

import UIKit

final class ImageCacheManager: ObservableObject {
    @Published var cachedPhotos: [String: CachedPhotoInfo] = [:]
    @Published var cachedImagesCount: Int = 0
    @Published var cacheSize: String = "0 MB"
    @Published var isLoading: Bool = false
    
    private let temporaryDirectory: URL
    private let session = URLSession.shared
    private let unsplashService = UnsplashService()
    
    struct CachedPhotoInfo {
        let photo: UnsplashPhoto
        let localURL: URL
        let cachedDate: Date
        let size: Int64
    }
    
    init() {
        temporaryDirectory = FileManager.default.temporaryDirectory.appendingPathComponent("UnsplashCache")
        createCacheDirectoryIfNeeded()
        loadExistingCache()
        setupMemoryWarningObserver()
    }
    
    // MARK: - Public Methods
    
    func downloadRandomPhoto(params: UnsplashSearchParams? = nil) async throws -> UnsplashPhoto {
        await MainActor.run { isLoading = true }
        
        do {
            let photo = try await unsplashService.getRandomPhoto(params: params)
            try await cachePhoto(photo)
            
            await MainActor.run { isLoading = false }
            return photo
            
        } catch {
            await MainActor.run { isLoading = false }
            throw error
        }
    }
    
    func downloadRandomPhotos(count: Int = 5, params: UnsplashSearchParams? = nil) async throws -> [UnsplashPhoto] {
        await MainActor.run { isLoading = true }
        
        do {
            let photos = try await unsplashService.getRandomPhotos(count: count, params: params)
            
            await withTaskGroup(of: Void.self) { group in
                for photo in photos {
                    group.addTask {
                        try? await self.cachePhoto(photo)
                    }
                }
            }
            
            await MainActor.run { isLoading = false }
            return photos
            
        } catch {
            await MainActor.run { isLoading = false }
            throw error
        }
    }
    
    func downloadPopularPhotos(count: Int = 10) async throws -> [UnsplashPhoto] {
        await MainActor.run { isLoading = true }
        
        do {
            let photos = try await unsplashService.getPhotos(perPage: count)
            
            await withTaskGroup(of: Void.self) { group in
                for photo in photos {
                    group.addTask {
                        try? await self.cachePhoto(photo)
                    }
                }
            }
            
            await MainActor.run { isLoading = false }
            return photos
            
        } catch {
            await MainActor.run { isLoading = false }
            throw error
        }
    }
    
    func getCachedPhotoInfo(for photoId: String) -> CachedPhotoInfo? {
        return cachedPhotos[photoId]
    }
    
    func removePhoto(photoId: String) {
        guard let cachedInfo = cachedPhotos[photoId] else { return }
        
        do {
            try FileManager.default.removeItem(at: cachedInfo.localURL)
            cachedPhotos.removeValue(forKey: photoId)
            updateCacheStats()
        } catch {
            print("Error removing cached photo: \(error)")
        }
    }
    
    func clearCache() {
        for (_, cachedInfo) in cachedPhotos {
            try? FileManager.default.removeItem(at: cachedInfo.localURL)
        }
        cachedPhotos.removeAll()
        updateCacheStats()
    }
    
    func clearOldCache(olderThan days: Int = 7) {
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        
        for (photoId, cachedInfo) in cachedPhotos {
            if cachedInfo.cachedDate < cutoffDate {
                removePhoto(photoId: photoId)
            }
        }
    }
    
    func getCacheSizeInBytes() -> Int64 {
        return cachedPhotos.values.reduce(0) { $0 + $1.size }
    }
    
    // MARK: - Private Methods
    
    private func createCacheDirectoryIfNeeded() {
        if !FileManager.default.fileExists(atPath: temporaryDirectory.path) {
            try? FileManager.default.createDirectory(at: temporaryDirectory, withIntermediateDirectories: true)
        }
    }
    
    private func cachePhoto(_ photo: UnsplashPhoto) async throws {
        guard let imageURL = URL(string: photo.urls.regular) else {
            throw ImageCacheError.invalidURL
        }
        
        let fileName = "\(photo.id).jpg"
        let localURL = temporaryDirectory.appendingPathComponent(fileName)
        
        if FileManager.default.fileExists(atPath: localURL.path) {
            await MainActor.run {
                if cachedPhotos[photo.id] == nil {
                    let fileSize = getFileSize(at: localURL)
                    cachedPhotos[photo.id] = CachedPhotoInfo(
                        photo: photo,
                        localURL: localURL,
                        cachedDate: Date(),
                        size: fileSize
                    )
                    updateCacheStats()
                }
            }
            return
        }
        
        let (data, _) = try await session.data(from: imageURL)
        
        try data.write(to: localURL)
        
        await MainActor.run {
            cachedPhotos[photo.id] = CachedPhotoInfo(
                photo: photo,
                localURL: localURL,
                cachedDate: Date(),
                size: Int64(data.count)
            )
            updateCacheStats()
        }
    }
    
    private func loadExistingCache() {
        guard FileManager.default.fileExists(atPath: temporaryDirectory.path) else { return }
        
        do {
            let files = try FileManager.default.contentsOfDirectory(at: temporaryDirectory, includingPropertiesForKeys: [.fileSizeKey, .creationDateKey])
            
            for fileURL in files where fileURL.pathExtension == "jpg" {
                let photoId = fileURL.deletingPathExtension().lastPathComponent
                let fileSize = getFileSize(at: fileURL)
                let creationDate = getCreationDate(at: fileURL)
                
                let dummyPhoto = createDummyPhoto(id: photoId)
                
                cachedPhotos[photoId] = CachedPhotoInfo(
                    photo: dummyPhoto,
                    localURL: fileURL,
                    cachedDate: creationDate,
                    size: fileSize
                )
            }
            
            updateCacheStats()
        } catch {
            print("Error loading existing cache: \(error)")
        }
    }
    
    private func createDummyPhoto(id: String) -> UnsplashPhoto {
        return UnsplashPhoto(
            id: id,
            createdAt: "",
            updatedAt: "",
            width: 0,
            height: 0,
            color: "#000000",
            blurHash: nil,
            likes: 0,
            likedByUser: false,
            description: "Cached image",
            altDescription: nil,
            user: UnsplashUser(
                id: "",
                username: "unknown",
                name: "Unknown User",
                firstName: nil,
                lastName: nil,
                portfolioURL: nil,
                bio: nil,
                location: nil,
                totalLikes: nil,
                totalPhotos: nil,
                totalCollections: nil,
                profileImage: nil,
                links: nil
            ),
            urls: UnsplashURLs(
                raw: "",
                full: "",
                regular: "",
                small: "",
                thumb: ""
            ),
            links: nil
        )
    }
    
    private func getFileSize(at url: URL) -> Int64 {
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            return attributes[.size] as? Int64 ?? 0
        } catch {
            return 0
        }
    }
    
    private func getCreationDate(at url: URL) -> Date {
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            return attributes[.creationDate] as? Date ?? Date()
        } catch {
            return Date()
        }
    }
    
    private func updateCacheStats() {
        cachedImagesCount = cachedPhotos.count
        
        let totalSize = cachedPhotos.values.reduce(0) { $0 + $1.size }
        let sizeInMB = Double(totalSize) / (1024 * 1024)
        cacheSize = String(format: "%.2f MB", sizeInMB)
    }
    
    private func setupMemoryWarningObserver() {
        NotificationCenter.default.addObserver(
            forName: UIApplication.didReceiveMemoryWarningNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleMemoryWarning()
        }
    }
    
    func handleMemoryWarning() {
        clearOldCache(olderThan: 1)
        
        if getCacheSizeInBytes() > 50 * 1024 * 1024 {
            let sortedPhotos = cachedPhotos.sorted { $0.value.cachedDate < $1.value.cachedDate }
            let toRemove = sortedPhotos.prefix(sortedPhotos.count / 2)
            
            for (photoId, _) in toRemove {
                removePhoto(photoId: photoId)
            }
        }
    }
}
