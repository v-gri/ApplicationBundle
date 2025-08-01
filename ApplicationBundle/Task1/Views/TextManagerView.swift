//
//  TextManagerView.swift
//  ApplicationBundle
//
//  Created by Vika on 27.07.25.
//

import SwiftUI

struct TextManagerView: View {
    @StateObject private var viewModel = TextManagerViewModel()
    @FocusState private var focusedField: FocusedField?

    enum FocusedField {
        case fileName
        case fileContent
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Input Section
                    createNewFileSection
                    
                    Divider()
                    
                    // Saved Files Section
                    savedFilesSection
                    
                    Spacer(minLength: 50)
                }
                .padding()
            }
            .contentShape(Rectangle())
            .onTapGesture {
                focusedField = nil
            }
            .navigationTitle("Text Manager")
            .alert("Message", isPresented: $viewModel.showAlert) {
                Button("OK") { }
            } message: {
                Text(viewModel.alertMessage)
            }
            .sheet(isPresented: $viewModel.showFileViewer) {
                FileViewerSheet(
                    fileName: viewModel.selectedFile ?? "",
                    fileContent: viewModel.fileContent,
                    onDelete: {
                        if let fileName = viewModel.selectedFile {
                            viewModel.deleteFile(fileName: fileName)
                        }
                    }
                )
            }
        }
    }
    
    private var createNewFileSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Create New Text File")
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(spacing: 12) {
                TextField("Enter filename", text: $viewModel.fileName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .focused($focusedField, equals: .fileName)
                    .onSubmit {
                        focusedField = .fileContent
                    }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("File Content:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    TextEditor(text: $viewModel.inputText)
                        .frame(minHeight: 120)
                        .focused($focusedField, equals: .fileContent)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                }
                
                Button("Append Text to File") {
                    viewModel.saveTextFile()
                    focusedField = nil
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.fileName.isEmpty || viewModel.inputText.isEmpty)
                .frame(maxWidth: .infinity)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.1))
        )
    }
    
    private var savedFilesSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Saved Files")
                    .font(.headline)
                    .foregroundColor(.primary)
            }
            
            if viewModel.savedFiles.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "doc.text")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                    
                    Text("No saved files")
                        .foregroundColor(.gray)
                        .italic()
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 30)
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(viewModel.savedFiles, id: \.self) { file in
                        FileRowView(
                            fileName: file,
                            onTap: {
                                viewModel.loadFileContent(fileName: file)
                            },
                            onDelete: {
                                viewModel.deleteFile(fileName: file)
                            }
                        )
                    }
                }
            }
        }
    }
}

struct TextManagerView_Previews: PreviewProvider {
    static var previews: some View {
        TextManagerView()
    }
}
