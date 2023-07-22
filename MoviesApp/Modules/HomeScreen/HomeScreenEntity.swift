//
//  HomeScreenEntity.swift
//  MoviesApp
//
//  Created by ardy on 21/07/23.
//

import Foundation

struct GenreEntity: Codable {
    let genres: [GenreData]?
}

struct GenreData: Codable {
    let id: Int?
    let name: String?
}
