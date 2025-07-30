//
//  FileViewerSheet.swift
//  ApplicationBundle
//
//  Created by Vika on 27.07.25.
//

import SwiftUI

struct FileViewerSheet: View {
    let fileName: String
    let fileContent: String
    let onDelete: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // File Info
                    VStack(alignment: .leading, spacing: 8) {
                        Text("File Information")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        HStack {
                            Image(systemName: "doc.text")
                                .foregroundColor(.blue)
                            
                            Text(fileName)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.gray.opacity(0.1))
                        )
                    }
                    
                    Divider()
                    
                    // File Content
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Content")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text(fileContent)
                            .font(.body)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.gray.opacity(0.1))
                            )
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("File Viewer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Delete") {
                        onDelete()
                        dismiss()
                    }
                    .foregroundColor(.red)
                }
            }
        }
    }
}
