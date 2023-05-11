//
//  BooksDataStorage.swift
//  BookSearchMoyaMap
//
//  Created by uejo on 2020/05/08.
//  Copyright © 2020 uejo. All rights reserved.
//

import Foundation

//ImageLinks内のデータ構造
struct ImageLinks: Codable {
    let thumbnail: String?
    let smallThumbnail: String?
}

//VolumeInfo内のデータ構造
struct VolumeInfo: Codable {
    let title: String?
    let authors: [String]?
    let imageLinks: ImageLinks?
    let infoLink: String?
    let publishedDate: String?
    let description: String?
}

//Items内のデータ構造
struct BookItem: Codable {
    let id: String?
    let volumeInfo: VolumeInfo?
}

//全てのデータの構造
struct TotalItems: Codable {
    let items: [BookItem]?
}
