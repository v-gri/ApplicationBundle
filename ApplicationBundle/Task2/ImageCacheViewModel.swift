//
//  ImageCacheViewModel.swift
//  ApplicationBundle
//
//  Created by Vika on 27.07.25.
//


import SwiftUI

@MainActor
class ImageCacheViewModel: ObservableObject {
    @Published var cachedPhotos: [String: ImageCacheManager.CachedPhotoInfo] = [:]
    @Published var cachedImagesCount: Int = 0
    @Published var cacheSize: String = "0 MB"
    @Published var isLoading: Bool = false
    @Published var alertMessage: String = ""
    @Published var showAlert: Bool = false
    @Published var selectedPhoto: UnsplashPhoto?
    
    let cacheManager = ImageCacheManager()
    var searchQuery: String = ""
    var selectedOrientation: UnsplashOrientation?
    var selectedCategory: UnsplashCategory?
    
    init() {
        updateCacheStats()
        setupMemoryWarningObserver()
    }
    
    func updateCacheStats() {
        cachedImagesCount = cacheManager.cachedImagesCount
        let totalSize = cacheManager.getCacheSizeInBytes()
        let sizeInMB = Double(totalSize) / (1024 * 1024)
        cacheSize = String(format: "%.2f MB", sizeInMB)
        cachedPhotos = cacheManager.cachedPhotos
    }
    
    func downloadRandomPhoto() async {
        isLoading = true
        do {
            let params = createSearchParams()
            _ = try await cacheManager.downloadRandomPhoto(params: params)
            updateCacheStats()
            showSuccessAlert("Random photo downloaded successfully!")
        } catch {
            showErrorAlert("Failed to download photo: \(error.localizedDescription)")
        }
        isLoading = false
    }
    
    func downloadMultiplePhotos(count: Int = 5) async {
        isLoading = true
        do {
            let params = createSearchParams()
            _ = try await cacheManager.downloadRandomPhotos(count: count, params: params)
            updateCacheStats()
            showSuccessAlert("\(count) random photos downloaded successfully!")
        } catch {
            showErrorAlert("Failed to download photos: \(error.localizedDescription)")
        }
        isLoading = false
    }
    
    func downloadPopularPhotos(count: Int = 10) async {
        isLoading = true
        do {
            _ = try await cacheManager.downloadPopularPhotos(count: count)
            updateCacheStats()
            showSuccessAlert("Popular photos downloaded successfully!")
        } catch {
            showErrorAlert("Failed to download popular photos: \(error.localizedDescription)")
        }
        isLoading = false
    }
    
    func clearOldCache(olderThan days: Int = 7) {
        cacheManager.clearOldCache(olderThan: days)
        updateCacheStats()
        showSuccessAlert("Old cache cleared successfully!")
    }
    
    func clearAllCache() {
        cacheManager.clearCache()
        updateCacheStats()
        showSuccessAlert("All cache cleared successfully!")
    }
    
    func removePhoto(photoId: String) {
        cacheManager.removePhoto(photoId: photoId)
        updateCacheStats()
    }
    
    func setSearchQuery(_ query: String) {
        searchQuery = query
    }
    
    func setOrientation(_ orientation: UnsplashOrientation?) {
        selectedOrientation = orientation
    }
    
    func setCategory(_ category: UnsplashCategory?) {
        selectedCategory = category
    }
    
    private func createSearchParams() -> UnsplashSearchParams? {
        let query = searchQuery.isEmpty ? nil : searchQuery
        if query == nil && selectedOrientation == nil && selectedCategory == nil {
            return nil
        }
        return UnsplashSearchParams(
            query: query,
            orientation: selectedOrientation,
            category: selectedCategory
        )
    }
    
    private func showSuccessAlert(_ message: String) {
        alertMessage = message
        showAlert = true
    }
    
    private func showErrorAlert(_ message: String) {
        alertMessage = message
        showAlert = true
    }
    
    private func setupMemoryWarningObserver() {
        NotificationCenter.default.addObserver(
            forName: UIApplication.didReceiveMemoryWarningNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            DispatchQueue.main.async { 
                self.cacheManager.handleMemoryWarning()
                self.updateCacheStats()
            }
        }
    }
}
