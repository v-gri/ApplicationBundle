//
//  Ext+FileManager.swift
//  ApplicationBundle
//
//  Created by Vika on 27.07.25.
//

import Foundation

extension TextFileManager {
    /// Creates a TextFileManager instance, returning nil on error
    static func create() -> TextFileManager? {
        do {
            return try TextFileManager()
        } catch {
            print("Failed to create TextFileManager: \(error)")
            return nil
        }
    }
}
