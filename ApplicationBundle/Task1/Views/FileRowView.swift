//
//  FileRowView.swift
//  ApplicationBundle
//
//  Created by Vika on 27.07.25.
//

import SwiftUI

struct FileRowView: View {
    let fileName: String
    let onTap: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: "doc.text")
                .foregroundColor(.blue)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(fileName)
                    .font(.body)
                    .foregroundColor(.primary)
                
                Text("Tap to view")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button("Delete") {
                onDelete()
            }
            .foregroundColor(.red)
            .buttonStyle(.bordered)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.05))
        )
        .onTapGesture {
            onTap()
        }
    }
}
