//
//  BundledImage.swift
//  ApplicationBundle
//
//  Created by Vika on 27.07.25.
//

import UIKit

struct BundledImage: Identifiable {
    let id: UUID
    let image: UIImage
    let title: String
    let description: String
    let tags: [String]
}
