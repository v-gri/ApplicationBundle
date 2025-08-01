//
//  TextManagerViewModel.swift
//  ApplicationBundle
//
//  Created by Vika on 27.07.25.
//

import SwiftUI

@MainActor
final class TextManagerViewModel: ObservableObject {
    @Published var inputText: String = ""
    @Published var fileName: String = ""
    @Published var savedFiles: [String] = []
    @Published var selectedFile: String?
    @Published var fileContent: String = ""
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    @Published var showFileViewer: Bool = false
    @Published var isLoading: Bool = false
    @Published var didSaveSuccessfully: Bool = false

    private let textManager: TextFileManager?
    
    init() {
        self.textManager = TextFileManager.create()
        
        if textManager == nil {
            alertMessage = "Failed to initialize file manager. The app may not function properly."
            showAlert = true
        } else {
            loadSavedFiles()
        }
    }
    
    // MARK: - Public Methods
    
    func saveTextFile() {
        guard let textManager = textManager else {
            showError("File manager is not available")
            return
        }
        
        guard !fileName.isEmpty && !inputText.isEmpty else {
            showError("Please provide both filename and content")
            return
        }
        
        isLoading = true
        
        let result = textManager.appendTextToFile(content: inputText, fileName: fileName + ".txt")

        switch result {
        case .success:
            showSuccess("Text appended to '\(fileName).txt' successfully!")
            clearInputFields()
            loadSavedFiles()
            didSaveSuccessfully = true
        case .failure(let error):
            showError("Error saving file: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
    
    func loadSavedFiles() {
        guard let textManager = textManager else { return }
        
        let result = textManager.getSavedFiles()
        
        switch result {
        case .success(let files):
            savedFiles = files
        case .failure(let error):
            showError("Error loading files: \(error.localizedDescription)")
            savedFiles = []
        }
    }
    
    func loadFileContent(fileName: String) {
        guard let textManager = textManager else {
            showError("File manager is not available")
            return
        }
        
        isLoading = true
        
        let result = textManager.loadTextFile(fileName: fileName)
        
        switch result {
        case .success(let content):
            fileContent = content
            selectedFile = fileName
            showFileViewer = true
        case .failure(let error):
            showError("Error loading file: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
    
    func deleteFile(fileName: String) {
        guard let textManager = textManager else {
            showError("File manager is not available")
            return
        }
        
        let result = textManager.deleteTextFile(fileName: fileName)
        
        switch result {
        case .success:
            showSuccess("File deleted successfully!")
            loadSavedFiles()
            
            // Closing viewer if delete current file
            if selectedFile == fileName {
                clearFileContent()
            }
        case .failure(let error):
            showError("Error deleting file: \(error.localizedDescription)")
        }
    }
    
    func fileExists(fileName: String) -> Bool {
        return textManager?.fileExists(fileName: fileName) ?? false
    }
    
    func clearFileContent() {
        fileContent = ""
        selectedFile = nil
        showFileViewer = false
    }
    
    // MARK: - Private Methods
    
    private func clearInputFields() {
        inputText = ""
        fileName = ""
    }
    
    private func showError(_ message: String) {
        alertMessage = message
        showAlert = true
    }
    
    private func showSuccess(_ message: String) {
        alertMessage = message
        showAlert = true
    }
}

extension TextManagerViewModel {
    var canSaveFile: Bool {
        !fileName.isEmpty && !inputText.isEmpty && !isLoading
    }
    
    var isFileManagerAvailable: Bool {
        textManager != nil
    }
}
