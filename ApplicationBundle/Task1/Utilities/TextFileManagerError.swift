//
//  TextFileManagerError.swift
//  ApplicationBundle
//
//  Created by Vika on 27.07.25.
//

import Foundation

enum TextFileManagerError: LocalizedError {
    case documentsDirectoryNotFound
    case invalidFileName
    case fileNotFound
    case writeError(Error)
    case appendError(Error)
    case readError(Error)
    case deleteError(Error)
    case directoryListingError(Error)
    
    var errorDescription: String? {
        switch self {
        case .documentsDirectoryNotFound:
            return "Documents directory not found"
        case .invalidFileName:
            return "Invalid file name provided"
        case .fileNotFound:
            return "File not found"
        case .writeError(let error):
            return "Failed to write file: \(error.localizedDescription)"
        case .appendError(let error):
            return "Failed to append to file: \(error.localizedDescription)"
        case .readError(let error):
            return "Failed to read file: \(error.localizedDescription)"
        case .deleteError(let error):
            return "Failed to delete file: \(error.localizedDescription)"
        case .directoryListingError(let error):
            return "Failed to list directory contents: \(error.localizedDescription)"
        }
    }
}
