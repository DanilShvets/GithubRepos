//
//  Protocols.swift
//  GithubRepos
//
//  Created by Данил Швец on 02.12.2024.
//

import Foundation
import Combine

protocol RepositoryService {
  func fetchRepositories(query: String, page: Int) async throws -> [GithubRepository]
}

protocol FavoritesService {
  var favoriteIds: Set<String> { get }
}

protocol StorageService {
  func getFavorites() async -> [FavoriteRepository]
  func addFavorite(_ repository: GithubRepository) async
  func deleteFavorite(_ repository: FavoriteRepository) async
  func updateOrder(_ favorites: [FavoriteRepository]) async
}
