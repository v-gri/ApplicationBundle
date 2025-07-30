//
//  ApplicationBundleApp.swift
//  ApplicationBundle
//
//  Created by Vika on 27.07.25.
//

import SwiftUI

@main
struct ApplicationBundleApp: App {
    var body: some Scene {
        WindowGroup {
            TabView {
                TextManagerView()
                    .tabItem {
                        Label("Text", systemImage: "doc.plaintext")
                    }

                ImageCacheView()
                    .tabItem {
                        Label("Images", systemImage: "photo")
                    }

                BundledContentView()
                    .tabItem {
                        Label("Bundle", systemImage: "folder")
                    }
            }
        }
    }
}
