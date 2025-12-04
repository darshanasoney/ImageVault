//
//  Image.swift
//  ImageVault
//
//  Created by Macbook Pro on 04/12/25.
//


import Foundation

struct Image: Codable, Identifiable {
    let id: UUID
    let filename: String
    let filesize: Int
    let savedAt: Date
}
