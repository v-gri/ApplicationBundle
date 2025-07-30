//
//  TextFileManager.swift
//  ApplicationBundle
//
//  Created by Vika on 27.07.25.
//

import Foundation

final class TextFileManager {
    private let documentsDirectory: URL
    
    init() throws {
        guard let directory = FileManager.default.urls(for: .documentDirectory,
                                                      in: .userDomainMask).first else {
            throw TextFileManagerError.documentsDirectoryNotFound
        }
        self.documentsDirectory = directory
    }
    
    // MARK: - Public Methods: file - save, load, delete, exist, size
    
    func saveTextFile(content: String, fileName: String) -> Result<Void, TextFileManagerError> {
        guard isValidFileName(fileName) else {
            return .failure(.invalidFileName)
        }
        
        let sanitizedFileName = sanitizeFileName(fileName)
        let fileURL = documentsDirectory.appendingPathComponent("\(sanitizedFileName).txt")
        
        do {
            try content.write(to: fileURL, atomically: true, encoding: .utf8)
            return .success(())
        } catch {
            return .failure(.writeError(error))
        }
    }
    
    func loadTextFile(fileName: String) -> Result<String, TextFileManagerError> {
        guard isValidFileName(fileName) else {
            return .failure(.invalidFileName)
        }
        
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return .failure(.fileNotFound)
        }
        
        do {
            let content = try String(contentsOf: fileURL, encoding: .utf8)
            return .success(content)
        } catch {
            return .failure(.readError(error))
        }
    }
    
    func deleteTextFile(fileName: String) -> Result<Void, TextFileManagerError> {
        guard isValidFileName(fileName) else {
            return .failure(.invalidFileName)
        }
        
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return .failure(.fileNotFound)
        }
        
        do {
            try FileManager.default.removeItem(at: fileURL)
            return .success(())
        } catch {
            return .failure(.deleteError(error))
        }
    }
    
    func getSavedFiles() -> Result<[String], TextFileManagerError> {
        do {
            let files = try FileManager.default.contentsOfDirectory(atPath: documentsDirectory.path)
            let textFiles = files.filter { $0.hasSuffix(".txt") }
                                .sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }
            return .success(textFiles)
        } catch {
            return .failure(.directoryListingError(error))
        }
    }
    
    func fileExists(fileName: String) -> Bool {
        guard isValidFileName(fileName) else { return false }
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        return FileManager.default.fileExists(atPath: fileURL.path)
    }
    
    func getFileSize(fileName: String) -> Result<Int64, TextFileManagerError> {
        guard isValidFileName(fileName) else {
            return .failure(.invalidFileName)
        }
        
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: fileURL.path)
            if let fileSize = attributes[.size] as? Int64 {
                return .success(fileSize)
            } else {
                return .failure(.readError(NSError(domain: "FileAttributes", code: 1)))
            }
        } catch {
            return .failure(.readError(error))
        }
    }
    
    // MARK: - Private Methods: file - valid name
    

}

extension TextFileManager {
    private func isValidFileName(_ fileName: String) -> Bool {
        return !fileName.isEmpty &&
               !fileName.contains("/") &&
               !fileName.contains("\\") &&
               !fileName.contains(":") &&
               !fileName.contains("*") &&
               !fileName.contains("?") &&
               !fileName.contains("\"") &&
               !fileName.contains("<") &&
               !fileName.contains(">") &&
               !fileName.contains("|") &&
               fileName.trimmingCharacters(in: .whitespacesAndNewlines) == fileName
    }
    
    private func sanitizeFileName(_ fileName: String) -> String {
        let invalidCharacters = CharacterSet(charactersIn: "/\\:*?\"<>|")
        return fileName.components(separatedBy: invalidCharacters).joined(separator: "_")
    }
}
